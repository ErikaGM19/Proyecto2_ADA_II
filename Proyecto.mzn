  % Analisis y Diseño de Algoritmos II
% Proyecto 2: Minimización de la Polarización en una Población
% Integrantes:
% - Marcela Mazo Castro - 201843612
% - Erika García Muñoz - 202259395

include "globals.mzn";

%-----------------------------------Parametros-----------------------------------

% Entrada
int: n;                           % Número total de personas
int: m;                           % Número de posibles opiniones
array[1..m] of int: p;            % Distribución inicial de personas por opinión
array[1..m] of float: v;          % Valor asociado a las opiniones, en el rango [0,1]
array[1..m, 1..m] of float: c;    % Matriz de costos de cambios entre opiniones
array[1..m] of float: ce;         % Costos adicionales de mover a una opinión inicialmente vacía
float: ct;                        % Costo total máximo permitido
int: maxM;                        % Número máximo de movimientos permitidos

%-----------------------------------Variables-----------------------------------

% Salida
array[1..m, 1..m] of var 0..n: x;      % x[i,j]: Número de personas que cambian de la opinión i a la opinión j
array[1..m] of var 0..n: p_new;        % Nueva distribución de personas por opinión después de los movimientos
array[0..m] of var 0..n: cum_p;        % Suma acumulada de p_new
var int: W;                            % Peso total
var 1..m: k;                           % Índice de la mediana
var float: mediana;                    % Mediana ponderada
% Variable de polarización total
var float: Z;  % Polarización total, con cota inferior de 0 (sin límite superior definido)

%-----------------------------------Cálculos-----------------------------------

% Precalcular factores (float)
array[1..m] of float: factor = [1.0 + p[i] / n | i in 1..m];

% Precalcular costo por persona entre opiniones (float)
array[1..m, 1..m] of float: cost_per_person = array2d(1..m, 1..m, 
    [ c[i, j] * factor[i] + (if p[j] = 0 then ce[j] else 0.0 endif) | i in 1..m, j in 1..m ]);

%-----------------------------------Restricciones-----------------------------------

% 1. Nadie se mueve a la misma opinión
constraint forall(i in 1..m)(
    x[i, i] = 0
);

% 2. Capacidad de movimiento
constraint forall(i in 1..m)(
    sum(j in 1..m)(x[i, j]) <= p[i]
);

% 3. Nueva distribución de personas
constraint forall(i in 1..m)(
    p_new[i] = p[i] + sum(j in 1..m)(x[j, i] - x[i, j])
);

% 4. Suma acumulada de p_new
constraint cum_p[0] = 0;
constraint forall(i in 1..m)(
    cum_p[i] = cum_p[i - 1] + p_new[i]
);

% 5. Peso total
constraint W = cum_p[m];

% 6. Restricciones para encontrar el índice de la mediana
constraint 2 * cum_p[k] >= W;
constraint (k = 1) \/ (2 * cum_p[k - 1] < W);

% 7. Definición de la mediana ponderada
constraint mediana = v[k];

% 8. Cálculo de la polarización total
constraint Z = sum(i in 1..m)(p_new[i] * abs(v[i] - mediana));

% 9. Restricción de costo total
constraint sum(i in 1..m, j in 1..m)(
    cost_per_person[i, j] * int2float(x[i, j])
) <= ct;

% 10. Restricción de movimientos máximos
constraint sum(i in 1..m, j in 1..m)(
    abs(i - j) * x[i, j]
) <= maxM;

% 11. Restricción de conservación de personas
constraint sum(i in 1..m)(p_new[i]) = n;

% 12. Acotar x[i,j]
constraint forall(i in 1..m, j in 1..m)(
    x[i, j] <= p[i]
);

%-----------------------------------Funcion Objetivo-----------------------------------

% Resolver minimizando la polarización total
solve minimize Z;

%-----------------------------------Salida-----------------------------------

output [
    "La mediana ponderada es: ", show(mediana), "\n",
    "Polarización total (suma de desviaciones absolutas ponderadas): ", show(Z), "\n",
    "Nueva distribución de opiniones: ", show(p_new), "\n",
    "Distribución de movimientos (x): ", show(x), "\n",
];
