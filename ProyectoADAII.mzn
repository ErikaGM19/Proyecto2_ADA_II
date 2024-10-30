% Analisis y Diseño de Algoritmos II
% Proyecto 2: Minimización de la Polarizacion en una Poblacion
% Integrantes:
% - Marcela Mazo Castro - 201843612
% - Erika García Muñoz - 202259395

%-----------------------------------Parametros-----------------------------------

% Entrada
int: n;                           % Número total de personas
int: m;                           % Número de posibles opiniones
array[1..m] of int: pi;           % Número de personas que tienen la opinión i
array[1..m] of float: vi;         % Valor asociado a la opinión i, en el rango [0,1]
array[1..m, 1..m] of int: ci,j;   % Matriz de costos para mover de la opinión i a la j
array[1..m] of int: cei;          % Costo adicional de mover a una opinión i si estaba vacía
int: ct;                          % Costo total máximo permitido
int: maxM;                        % Número máximo de movimientos permitidos

%-----------------------------------Variables-----------------------------------

% Salida
array[1..m, 1..m] of var int: x;  % x[i,j]: Número de personas que cambian de la opinión i a la opinión j
array[1..m] of var int: z;        % z[j]: Número de personas que permanecen en la opinión j
array[1..m] of var int: y;        % y[i]: Indica si la opinión i es seleccionada para cambios (0 o 1)

%-----------------------------------Restricciones-----------------------------------

% Restricción de Cambio de Opiniones
constraint forall(i in 1..m) (sum(j in 1..m) (x[i, j]) <= max_moves);

% Restricción de Movimiento Total
constraint sum(i in 1..m, j in 1..m) (x[i, j]) <= maxM;

% Restricción de Costo Total
constraint sum(i in 1..m, j in 1..m) (c[i, j] * x[i, j]) <= ct;

% Restricción de Permanencia en Opiniones
constraint forall(j in 1..m) (z[j] + sum(i in 1..m) (x[i, j]) == total_population[j]);

% Restricción de Selección de Opiniones
constraint sum(i in 1..m) (y[i]) <= max_selected;

% Restricción de Binarias para Selección de Opiniones
constraint forall(i in 1..m) (y[i] in 0..1);

% Restricción de Polarización Final
constraint final_polarization = sum(j in 1..m) (abs(z[j] - average_population));

% Restricción de No Negatividad
constraint forall(i in 1..m, j in 1..m) (x[i, j] >= 0);

%-----------------------------------Funcion Objetivo-----------------------------------