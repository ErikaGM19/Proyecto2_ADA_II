Analisis y Diseño de Algoritmos II
 Proyecto 2: Minimización de la Polarización en una Población

Integrantes:
 - Marcela Mazo Castro - 201843612
 - Erika García Muñoz - 202259395

Descripción del proyecto:
MinPol es un proyecto de optimización diseñado para reducir la polarización de opiniones en una población 
mediante un modelo implementado en MiniZinc. Utilizando técnicas avanzadas de optimización como Branch and Bound 
y programación lineal, entera y mixta, el modelo busca encontrar una distribución de opiniones que minimice los 
conflictos y fomente la cohesión social.

El sistema permite cargar datos en formato .mpl, que luego son convertidos a .dzn para su procesamiento
en MiniZinc. La interfaz gráfica en Python facilita la selección y ejecución de pruebas, mostrando 
los resultados en tiempo real para facilitar el análisis y la comparación.

Video Explicativo: https://youtu.be/ZfTdVboag4k

Directorios y Archivos entregados: 
- Carpeta DatosProyecto : carpeta que contiene los archivos.dzn
- Carpeta MisInstancias : carpeta que contiene los archivos.mpl
- Carpeta ProyectoGUIFuentes : carpeta que contiene los archivos de la interfaz grafica
- Archivo Proyecto.mzn : archivo del modelo de minizinc
- Archivo Informe.pdf : archivo del informe del proyecto -----------PENDIENTE
- Archivo Readme.txt  : archivo con la descripcion y contextualizacion del proyecto

Requisitos del sistema:
- tener Python instalado
- tener instalada la libreria tkinter
- tener MiniZinc instalado y configurado en PATH en variables del sistema

Ejecución de la Aplicación:
- Abrir el archivo de la aplicación con un IDE preferiblemente Visual Studio Code, desde la raiz "Proyecto2_ADA_II".
- Entrar a la carpeta ProyectoGUIFuentes.
- Ejecutar el archivo main.py
- Presionar el desplegable "Seleccionar entrada" y seleccionar una prueba en formato mpl de la carpeta MisInstancias.
- Al cargar el archivo .mpl inmediatamente se transforma a .dzn y se guarda en DatosProyecto
- Presionar el boton "Minimizar" para visualizar las respuestas.
