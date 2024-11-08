import customtkinter as ctk  # Librería para la interfaz gráfica
import os
import subprocess
from tkinter import filedialog  # Importación del módulo para abrir el diálogo de archivos
from PIL import Image, ImageTk  # Importar las clases Image y ImageTk de la librería Pillow
import time

# Inicializamos la aplicación y configuramos el tema
ctk.set_appearance_mode("dark")
ctk.set_default_color_theme("dark-blue")

# Crear la ventana principal
root = ctk.CTk()
root.geometry("1000x600")  # Tamaño inicial de la ventana
root.title("Proyecto II - ADA II - Grupo 8")

# Variable global para almacenar las entradas disponibles y las entradas seleccionadas
entradas_disponibles = []
entrada_seleccionada = None
contenido_dzn = ""  # Variable global para almacenar el contenido del archivo .dzn


# Función para cargar el archivo de prueba seleccionado
def cargar_archivo(prueba):
    global contenido_dzn
    try:
        carpeta_pruebas = "MisInstancias"
        ruta_prueba = os.path.join(carpeta_pruebas, prueba)
        with open(ruta_prueba, "r") as archivo:
            datos_entrada = archivo.readlines()  # Leer todas las líneas del archivo
            datos_entrada = [line.strip() for line in datos_entrada]  # Limpiar espacios en blanco
            contenido_dzn = mpl_to_dzn(datos_entrada, prueba.replace('.mpl', '.dzn'))
            resultado_area.insert(ctk.END, f"Archivo '{prueba}' transformado y guardado exitosamente en: DatosProyecto/{prueba.replace(".mpl", ".dzn")}\n")
    except Exception as e:
        resultado_area.insert(ctk.END, f"Error al cargar la entrada: {str(e)}\n")
        return None

# Función para transformar el archivo .mpl a .dzn
def mpl_to_dzn(datos, nombre_dzn):
    try:
        # Extraer datos según el formato proporcionado
        n = datos[0]
        m = datos[1]
        p = datos[2]
        v = datos[3]
        ce = datos[4]
        
        # Construir la matriz 'c' en formato array2d
        matriz_c = ",\n".join(line.strip() for line in datos[5:5 + int(m)])
        
        ct = datos[5 + int(m)].replace(";", "")
        maxM = datos[6 + int(m)].replace(";", "")

        # Crear el contenido del archivo .dzn con el formato deseado
        contenido_dzn = (
            f"n = {n};\n"
            f"m = {m};\n"
            f"p = [{p}];\n"
            f"v = [{v}];\n"
            f"c = array2d(1..{m}, 1..{m}, [\n{matriz_c}\n]);\n"
            f"ce = [{ce}];\n"
            f"ct = {ct};\n"
            f"maxM = {maxM};\n"
        )

        # Guardar el archivo en la carpeta 'DatosProyecto'
        carpeta_salida = "DatosProyecto"
        os.makedirs(carpeta_salida, exist_ok=True)
        ruta_salida = os.path.join(carpeta_salida, nombre_dzn)
        with open(ruta_salida, "w") as archivo_dzn:
            archivo_dzn.write(contenido_dzn)
        return contenido_dzn 
    except Exception as e:
        resultado_area.insert(ctk.END, f"Error en la transformación: {str(e)}\n")
        return ""

# Función para ejecutar el modelo MiniZinc    
def ejecutar_minimizacion():
    global contenido_dzn
    try:
        # Ruta del archivo del modelo y archivo .dzn generado
        modelo_path = "Proyecto.mzn"
        archivo_dzn_path = os.path.join("DatosProyecto", entrada_seleccionada.replace(".mpl", ".dzn"))
        # Comando para ejecutar MiniZinc y capturar la salida
        comando = f'minizinc --solver gecode --all-solutions {modelo_path} {archivo_dzn_path}'
        resultado = subprocess.run(comando, shell=True, capture_output=True, text=True)
        
        # Mostrar el resultado en el área de texto
        if resultado.returncode == 0:
            resultado_area.insert(ctk.END, f"Resultado de la minimización para '{entrada_seleccionada}':\n{resultado.stdout}\n")
        else:
            resultado_area.insert(ctk.END, f"Error en la minimización: {resultado.stderr}\n")
    except Exception as e:
        resultado_area.insert(ctk.END, f"Error al ejecutar MiniZinc: {str(e)}\n")

# Función para obtener todas las pruebas disponibles en la carpeta "Pruebas"
def obtener_entradas():
    global entradas_disponibles
    carpeta_pruebas = "MisInstancias"
    try:
        # Listar los archivos .txt en la carpeta de pruebas
        entradas_disponibles = [f for f in os.listdir(carpeta_pruebas) if f.endswith(".mpl")]
        if entradas_disponibles:
            entradas_disponibles = sorted(entradas_disponibles, key=lambda x: int(''.join(filter(str.isdigit, x))))
        else:
            entradas_disponibles = ["No hay entradas disponibles"]
    except FileNotFoundError:
        entradas_disponibles = ["Carpeta 'MisInstancias' no encontrada"]

# Función para actualizar las pruebas en el menú desplegable
def actualizar_entradas_menu():
    obtener_entradas()  # Obtener la lista de pruebas desde la carpeta
    opciones_pruebas.configure(values=entradas_disponibles)  # Actualizar el menú desplegable con las pruebas disponibles

# Función para seleccionar una prueba
def seleccionar_entrada(entrada):
    global entrada_seleccionada
    entrada_seleccionada = entrada
    resultado_area.insert(ctk.END, f"Entrada seleccionada: {entrada}\n")
    cargar_archivo(entrada)
    
# Crear la barra superior roja con el título
barra_superior = ctk.CTkFrame(root, height=105, corner_radius=0, fg_color="darkred")  
barra_superior.grid(row=0, column=0, columnspan=3, sticky="ew")

# Título
titulo_label = ctk.CTkLabel(barra_superior, text="MINIMIZACIÓN DE LA POLARIZACIÓN EN UNA POBLACIÓN", font=("Montserrat", 20), text_color="white")
titulo_label.place(relx=0.5, rely=0.5, anchor="center")  # Centrar el título

# Cargar la imagen del logo
logo_image = Image.open("ProyectoGUIFuentes/logoUV_gris.jpg")
logo_image = logo_image.resize((95, 105))
logo_image_tk = ImageTk.PhotoImage(logo_image)

# Mostrar la imagen del logo
logo_label = ctk.CTkLabel(barra_superior, image=logo_image_tk, text="")
logo_label.grid(row=0, column=0, padx=0, pady=0)

# Crear el área izquierda
frame_resultados = ctk.CTkFrame(root, width=450, height=35, corner_radius=0, fg_color="gray30")
frame_resultados.grid(row=1, column=0, rowspan=2, sticky="nswe")

resultado_label = ctk.CTkLabel(frame_resultados, text="Resultado\nentradas minimizadas", font=("Montserrat", 10), text_color="white", justify="center")
resultado_label.grid(row=0, column=0, pady=10)

# Crear el área principal de contenido
frame_contenido = ctk.CTkFrame(root, fg_color="gray25", width=150, height=100)
frame_contenido.grid(row=1, column=1, sticky="ew", padx=10, pady=10)

# Título dentro del contenido
label_seleccion = ctk.CTkLabel(frame_contenido, text="Seleccione una entrada a minimizar", font=("Montserrat", 20))
label_seleccion.grid(row=0, column=0, pady=10, sticky="ew")

# Crear un marco para alinear los menús desplegables de forma horizontal
frame_menus_botones = ctk.CTkFrame(frame_contenido, fg_color="gray25")
frame_menus_botones.grid(row=1, column=0, pady=10, padx=10, sticky="ew")

# Alinear centrado el contenido dentro del frame
frame_menus_botones.grid_columnconfigure(0, weight=1)
frame_menus_botones.grid_columnconfigure((0, 1, 2, 3), weight=1)

# Menú desplegable para Entradas
opciones_pruebas = ctk.CTkOptionMenu(
    frame_menus_botones,
    values=["Seleccionar entrada"],
    command=seleccionar_entrada,  # Llama a seleccionar_prueba cuando se selecciona una prueba
    fg_color="darkred",
    button_color="darkred",
    button_hover_color="#c71818"
)
opciones_pruebas.grid(row=0, column=0, padx=10)

# Botón de "Ejecutar minimización"
btn_ejecutar_minimizacion = ctk.CTkButton(
    frame_menus_botones,
    text="Minimizar",
    fg_color="darkred",
    hover_color="darkred",
    command=ejecutar_minimizacion  
)
btn_ejecutar_minimizacion.grid(row=0, column=2, padx=10)

# Botón de "Detener ejecución"
btn_detener_ejecucion = ctk.CTkButton(
    frame_menus_botones,
    text="Detener ejecución",
    fg_color="darkred",
    hover_color="darkred",
    command=lambda: resultado_area.insert(ctk.END, "Ejecución detenida\n")
)
btn_detener_ejecucion.grid(row=0, column=3, padx=10)

# Crear el área para mostrar el resultado de la ejecución
frame_resultado = ctk.CTkFrame(root, fg_color="gray25", width=150, height=400)
frame_resultado.grid(row=2, column=1, sticky="nsew", padx=10, pady=10)

label_resultado = ctk.CTkLabel(frame_resultado, text="Resultado de la ejecución", font=("Montserrat", 30))
label_resultado.grid(row=0, column=0, pady=10)

# Crear el área de texto para mostrar resultados
resultado_area = ctk.CTkTextbox(frame_resultado, height=150, width=870)
resultado_area.grid(row=1, column=0, padx=10, pady=10, sticky="nsew")

# Ajustar el peso de las columnas y filas para que la interfaz sea más responsive 
root.grid_columnconfigure(1, weight=1)
root.grid_rowconfigure(2, weight=1)  
frame_resultado.grid_rowconfigure(1, weight=1)

# Actualizar el menú de pruebas al iniciar la aplicación
actualizar_entradas_menu()

# Ejecutar la aplicación
root.mainloop()