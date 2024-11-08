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
array[1..m] of var bool: y;            % y[i]: Variable binaria, indica si la opinión i recibe personas (si estaba vacía)
array[1..m] of var 0..n: p_new;        % Nueva distribución de personas por opinión después de los movimientos

% Variable de polarización total
var float: Z;  % Polarización total, con cota inferior de 0 (sin límite superior definido)

%-----------------------------------Cálculos-----------------------------------

% Calcular la nueva distribución de personas, p_new, en función de los movimientos realizados
constraint forall(i in 1..m) (
    p_new[i] = p[i] + sum(j in 1..m where j != i)(x[j, i] - x[i, j])
);

% Cálculo de la suma acumulada de pesos (p_new en este caso)
array[0..m] of var float: cum_p;  % Se cambia a var float para adaptarse a p_new
constraint cum_p[0] = 0.0;
constraint forall(i in 1..m) (
    cum_p[i] = cum_p[i - 1] + int2float(p_new[i])
);

% Peso total (suma de todos los pesos)
var float: W = cum_p[m];

% Variable para el índice de la mediana ponderada
var 1..m: k;

% Restricciones para encontrar el índice de la mediana ponderada
constraint cum_p[k] >= W / 2.0;
constraint (k = 1) \/ (cum_p[k - 1] < W / 2.0);

% Definición de la mediana ponderada
var float: mediana = v[k];

% Cálculo de la polarización total usando la mediana ponderada
constraint Z = sum(i in 1..m) (int2float(p_new[i]) * abs(v[i] - mediana));

%-----------------------------------Restricciones-----------------------------------

% 1. Restricción de Costo Total con el Factor Adicional
constraint 
    sum(i in 1..m, j in 1..m where i != j) (
        c[i, j] * (1.0 + int2float(p[i]) / int2float(n)) * int2float(x[i, j])
        + (p[j] = 0) * ce[j] * int2float(x[i, j])
    ) <= ct;

% 2. Restricción de Movimientos Máximos (Usando Distancia entre Opiniones)
constraint 
    sum(i in 1..m, j in 1..m where i != j) (
        abs(i - j) * x[i, j]
    ) <= maxM;
    
% 3. Restricción de Conservación de Personas

constraint sum(i in 1..m) (p_new[i]) = n;

%4. Restricción de Capacidad de Movimiento

constraint forall(i in 1..m) (
          sum(j in 1..m where j != i)(x[i, j]) <= p[i]
          );         

%-----------------------------------Variables-----------------------------------

% Variable de Selección de Opiniones 
constraint 
    sum(i in 1..m, j in 1..m where i != j) (
            c[i, j] * (1.0 + int2float(p[i]) / int2float(n)) * int2float(x[i, j])
            + (p[j] = 0) * ce[j] * int2float(x[i, j])
        ) <= ct;
        
%-----------------------------------Funcion Objetivo-----------------------------------

% Resolver minimizando la polarización total
solve minimize Z;

%-----------------------------------Salida-----------------------------------

output [
    "La mediana ponderada es: ", show(mediana), "\n",
    "Polarización total (suma de desviaciones absolutas ponderadas): ", show(Z), "\n",
    "Nueva distribución de opiniones: ", show(p_new), "\n",
    "Distribución de movimientos (x): ", show(x), "\n",
    "Variables binarias (y): ", show(y), "\n"
];
