% Analisis y Diseño de Algoritmos II
% Proyecto 2: Minimización de la Polarizacion en una Poblacion
% Integrantes:
% - Marcela Mazo Castro - 201843612
% - Erika García Muñoz - 202259395

%-----------------------------------Parametros-----------------------------------

% Entrada
int: n;                           % Número total de personas
int: m;                           % Número de posibles opiniones
array[1..m] of int: p;            % Número de personas que tienen una opinión
array[1..m] of float: v;          % Valor asociado a las opiniones , en el rango [0,1]
array[1..m * m] of int: c_flat;   % Matriz de costos de cambios
array[1..m] of int: ce;           % Costos adicionales de mover a una opinión i si estaba vacía
int: ct;                          % Costo total máximo permitido
int: maxM;                        % Número máximo de movimientos permitidos

array[1..m, 1..m] of int: c = array2d(1..m, 1..m, c_flat);  % Definir la matriz de costos `c` a partir de la lista plana `c_flat`
%-----------------------------------Variables-----------------------------------

% Salida
array[1..m, 1..m] of var 0..n: x;      % x[i,j]: Número de personas que cambian de la opinión i a la opinión j
array[1..m] of var bool: y;            % y[i]: Indica si la opinión i es seleccionada para cambios (0 o 1)   
array[1..m] of var int: cumulative_p;  % Distribución acumulativa de las opiniones


%-----------------------------------Mediana-------------------------------------

% Calcular la distribución acumulativa de las opiniones
constraint cumulative_p[1] = p[1];
constraint forall(i in 2..m) (
    cumulative_p[i] = cumulative_p[i - 1] + p[i]
);

% Encontrar el índice de la mediana
var int: median_index;
constraint median_index = min(i in 1..m where cumulative_p[i] >= n div 2) (i);

% Definir el valor de la mediana según el índice encontrado
var float: median = v[median_index];

%-----------------------------------Polarización---------------------------------

% Calcula la polarización usando valor absoluto
array[1..m] of var float: abs_diff;
constraint forall(i in 1..m) (
  abs_diff[i] = abs(v[i] - median)
);
var float: polarization = sum(i in 1..m) (p[i] * abs_diff[i]);

%-----------------------------------Restricciones-----------------------------------

% Restricción de costo total
constraint sum(i in 1..m, j in 1..m where i != j) (c[i, j] * x[i, j]) + sum(i in 1..m) (ce[i] * bool2int(y[i])) <= ct;

% Restricción de Movimiento Total
constraint sum(i in 1..m, j in 1..m where i != j) (x[i, j]) <= maxM;

% Restricción de conservación de personas: el número de personas que cambian no puede exceder el total disponible
constraint forall(j in 1..m) (
  p[j] + sum(i in 1..m where i != j) (x[i, j]) - sum(i in 1..m where i != j) (x[j, i]) >= 0
);

% Restricción de variable binaria y[i] para determinar si la opinión i recibe nuevas personas
constraint forall(i in 1..m) (
  (sum(j in 1..m where j != i) (x[j, i]) > 0) -> (y[i] = true)
);

constraint forall(i in 1..m) (
  (sum(j in 1..m where j != i) (x[j, i]) = 0) -> (y[i] = false)
);

% Restricción de No Negatividad
constraint forall(i in 1..m, j in 1..m) (x[i, j] >= 0);

%-----------------------------------Funcion Objetivo-----------------------------------

% Función objetivo: minimizar la polarización
solve minimize polarization;