<a name="top"></a>
# Bootcamp Desarrollo de Apps Móviles

---

<p align="center">
  <strong><span style="font-size:20px;">Módulo: Swift</span></strong>
</p>

---

<p align="center">
  <strong>Autor:</strong> Salva Moreno Sánchez
</p>

<p align="center">
  <a href="https://www.linkedin.com/in/salvador-moreno-sanchez/">
    <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn">
  </a>
</p>

## Índice

* [Contenidos dados en el módulo](#contenidos)
* [Herramientas](#herramientas)
* [Práctica: Gestión de reservas de hotel](#practica)
	* [Descripción](#descripcion)
	* [Características](#caracteristicas)
	* [Funcionalidades](#funcionalidades)
	* [Problemas, decisiones y resolución](#problemas)
		*  [Generación de IDs únicos](#id)
		*  [Adición de un caso de error más de los requeridos en la práctica](#casoError)
		*  [Tipo de dato `UInt8` para la edad de los clientes](#uint)

<a name="contenidos"></a>
## Contenidos dados en el módulo

| Swift básico  | Swift intermedio  | Swift avanzado |
|:-------------:|:---------------:|:-------------:|
| Tipos de datos básicos | Funciones | Closures |
| Variables y constantes | Enumeraciones (`enum`) | Propiedades |
| Operadores | Estructuras (`struct`) | Protocolos / Interfaces |
| Condicionales   | Clases (`class`) | Extensiones |
| Bucles | Manejo de memoria (ARC) | Control de errores |
| Conversión de tipos | Control de acceso | |
| Colecciones | Código genérico (generics) | |
| Cadenas de texto | | |
| Tuplas | | |
| Rangos | | |
| Opcionales / *nullables* | | |
| *Any, Data, URL, Date* | | |

<a name="herramientas"></a>
## Herramientas

<p align="center">

<a href="https://www.swift.org/documentation/">
    <img src="https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Git">
  </a>
  
  <a href="https://developer.apple.com/documentation/xcode">
    <img src="https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white" alt="GitHub">
  </a>
  
</p>

<a name="practica"></a>
## Práctica: Gestión de reservas de hotel

<a name="descripcion"></a>
### Descripción

Para poner en práctica lo aprendido y afianzar los conceptos vistos a lo largo del módulo de Swift, se nos ha propuesto el **desarrollo de un sistema para gestionar reservas de hotel**, el cual debe asegurar la consistencia del guardado, manejo y devolución de los datos en un escenario en el que se controlen los errores.

<a name="caracteristicas"></a>
### Características

* **Generales:**
	* Se han tenido en cuenta las siguientes características de la programación orientada a objetos como paradigma:
		* **Abstracción:** representación de objetos del mundo real.
		* **Encapsulación:** agrupación de datos y métodos en una clase controlando su accesibilidad desde el exterior.
		* **Métodos y atributos:** definición de los mismos para representar las características del objeto y sus funcionalidades.
* **Específicas:**
	* `struct` para la definición de clientes (se implementa protocolo `Equatable`) y reservas.
	* `enum` para la implementación de errores, ya sea con el uso del protocolo `Error` o `LocalizedError` (en este caso, se usa este).
	* `class` para gestionar las reservas del hotel.
	* Reservas con ID y cliente únicos, es decir, no se pueden repetir ninguno en otra reserva.

<a name="funcionalidades"></a>
### Funcionalidades

* **Almacenamiento de reservas**, siempre y cuando el ID y cualquier cliente no se repitan, por lo que todos estos escenarios a evitar se controlan con el lazamiento de errores.
* **Creación de IDs únicos**. Ejemplo de ID: `D22U8bIp84`.
* **Cálculo del precio** atendiendo al manejo de diversos parámetros como el número de clientes de la reserva, la posibilidad de desayuno y los días de estancia.
* **Cancelación de reservas** dado un ID y lanzando un error si no existe la reserva.
* **Devolución del listado de todas las reservas**, atendiendo, también, al aspecto visual e intuitivo en consola.
* **Clase dedicada a tests** para probar las diversas causísticas del código.

<a name="problemas"></a><a name="id"></a>
### Problemas, decisiones y resolución

* **Generación de IDs únicos**

Una de las problemáticas con las que tuve que lidiar fue cómo generaba los IDs únicos de cada reserva. El camino fácil hubiera sido la asignación de números enteros y, con un contador, ir sumando cada vez que se produzca el almacenamiento de una reserva. De esta forma, nunca habría problemas de repetición de ID. 

Sin embargo, quería realizar algo un poco más complejo, por lo que decidí crear IDs conformados por 5 números, 2 minúsculas y 3 mayúsculas; lo cual me llevó a pensar directamente en elaborar tres *arrays* con todos los números, mayúsculas y minúsculas respectivamente. No obstante, recordé las asignaciones númericas que se pueden realizar en el lenguaje de programación *Java* a variables de tipo `char`, las cuales nos dan acceso a una amplia gama de caracteres. Particularmente, me gusta su uso por características como:

* Ser un estándar de codificación de caracteres.
* Compatibilidad.
* Consistencia. 

Así fue que comencé a investigar en su aplicación en *Swift* y descubrí el tipo de dato `UnicodeScalar`. Con el mismo, sabiendo en qué rango numérico se sitúan los caracteres que nos interesan, podemos extraerlos de forma directa. Por ejemplo, el número 1 es `UnicodeScalar(49)`. Asimismo, realizándolo de esta forma, se evita un mayor consumo de memoria, por mínimo que sea.

Una vez generado, dicho ID es mezclado con el método `shuffled()` en pos de la seguridad y variabilidad de los mismos; y, a continuación, se comprueba si ya se ha generado anteriormente para otra reserva almacenada, por lo que la fiabilidad de poseer un ID único es muy alta. Además, en los tests realizados, nunca se ha llegado a errar en este paso.<a name="casoError"></a>

* **Adición de un caso de error respecto a los tres casos requeridos en la práctica**

En las exigencias del enunciado de la práctica se requería la implementación de tres casos de error: si se encuentra una reserva con el mismo ID, si se encuentra una reserva para un cliente y si no se encuentra reserva alguna.

No obstante, durante el desarrollo del método `addReservation` de la clase `HotelReservationManager`, surgió, a la hora de lanzar los errores a controlar, la problemática de que también se puede dar el caso de que simultáneamente se encuentre una reserva con el mismo ID y que un cliente a registrar ya esté agregado. Así, se ha añadido un caso que tenga asociado un `Array` compuesto de `Error`, quedando el `enum` de la siguiente manera:

```swift
enum ReservationError: LocalizedError {
    case reservationSameId
    case reservationFoundClient
    case noReservationFound
    case reservationSameIdAndClient([Error])
    
    var errorDescription: String? {
        switch self {
        case .reservationSameId:
            // ...
    }
}
```

Lanzando los errores de la siguiente forma:

```swift
// declarando los casos de error en el Array
let errors: [Error] = [ReservationError.reservationSameId, ReservationError.reservationFoundClient]
throw ReservationError.reservationSameIdAndClient(errors)
```

Y manejándolos así en un *do-catch* con un simple bucle:

```swift
do {
	// ...
} catch let ReservationError.reservationSameIdAndClient(errors) {
    for error in errors {
        print(error)
    }
}
```

Se podría pensar que la adición de este caso de error es innecesaria, ya que si se produce uno, la acción sería inválida independientemente de si ocurre el otro caso de error; sin embargo, dependería de lo que queramos analizar, pero veo interesante saber cuándo se produce sólo uno y cuándo ocurren los dos al mismo tiempo ya que nos puede ayudar a encontrar fallos en nuestro código y depurarlo.<a name="uint"></a>

* **Tipo de dato `UInt8` para la edad de los clientes**

Otra de las decisiones a destacar es la de asignar a la edad de los clientes el tipo de dato `UInt8` pudiendo emplear `Int` directamente. La decantación por el mismo se debe principalmente a que, en un contexto real, nadie va a tener 255 años; por lo que he considerado importante emplear dicho tipo de dato para **favorecer la eficiencia de la memoria** y, además, **evito que la variable `age` pueda poseer valores negativos**.


---

[Subir ⬆️](#top)