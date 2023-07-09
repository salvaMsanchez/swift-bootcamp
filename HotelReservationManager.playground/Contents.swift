//: # Bootcamp Desarrollo de Apps Móviles
//: ## Módulo: Swift
//: Autor: [Salva Moreno Sánchez](https://www.linkedin.com/in/salvador-moreno-sanchez/)
//: ### Código de la práctica
import Foundation


/// `struct` para definir a cualquier cliente del hotel e implementación del protocolo `Equatable` para comparar clientes y evitar repeticiones
struct Client: Equatable {
    /// Nombre del cliente.
    let name: String
    /// Edad del cliente.
    let age: UInt8 // se usa este tipo de dato por la imposibilidad de tener una edad por encima de 256
    /// Altura del cliente.
    let height: Int
    
}

/// `struct` para definir a cualquier reserva del hotel.
struct Reservation {
    /// Identificador único de reserva.
    let id: String
    /// Nombre del hotel.
    let hotelName: String
    /// Lista de clientes.
    let clientList: [Client]
    /// Duración de la estancia en el hotel en días.
    let days: Int
    /// Precio total de la reserva.
    let price: Double
    /// Booleano para confirmar si tienen derecho o no a desayuno.
    let breakfast: Bool
    
}

/// `enum` para definir los errores a controlar: se encontró reserva con el mismo ID, se encontró reserva para un cliente, no se encontró reserva o se ha encontrado reserva con el mismo ID y cliente.
enum ReservationError: LocalizedError {
    /// Reserva inválida por tener el mismo ID que otra.
    case reservationSameId
    /// Reserva inválida por encontrar un cliente ya almacenado en alguna otra reserva.
    case reservationFoundClient
    /// No se encuentra la reserva indicada.
    case noReservationFound
    /// Reserva inválida por, al mismo tiempo, tener el mismo ID que otra reserva y encontrar un cliente ya almacenado.
    case reservationSameIdAndClient([Error]) // se ha añadido este error por haberlo contemplado a la hora de lanzar errores en el método addReservation de la clase HotelReservationManager
    
    /// Descripción de los casos de error empleados en el enumerado, ya que se usa el protocolo `LocalizedError`.
    var errorDescription: String? {
        switch self {
        case .reservationSameId:
            return "ReservationError.reservationSameId: reservation found with the same ID"
        case .reservationFoundClient:
            return "ReservationError.reservationFoundClient: reservation found for a customer"
        case .noReservationFound:
            return "ReservationError.noReservationFound: no reservation found"
        case .reservationSameIdAndClient(_):
            return "ReservationError.reservationSameId: reservation found with the same ID and found for a customer"
        }
    }
    
}

/// `class` para gestionar las reservas del hotel.
class HotelReservationManager {
    /// Lista de las reservas realizadas.
    private var reservations: [Reservation] = []
    /// Constante con el nombre del hotel.
    private let hotelName: String = "The Grand Budapest Hotel"
    /// Lista de los IDs almacenados.
    private var containerId: [String] = []
    
    init() {}
    
    func getReservations() -> [Reservation] {
        return reservations
    }
    
    func getContainerId() -> [String] {
        return containerId
    }
    
    /// Almacena reserva si el ID es único entre las reservas ya guardadas y si algún cliente no coincide con aquellos de las reservas ya almacenadas.
    /// - Throws:
    ///   - `ReservationError.reservationSameIdAndClient(errors)`
    ///   Reserva inválida por, al mismo tiempo, tener el mismo ID que otra reserva y encontrar un cliente ya almacenado.
    ///   - `ReservationError.reservationFoundClient`
    ///   Reserva inválida por encontrar un cliente ya almacenado en alguna otra reserva.
    ///   - `ReservationError.reservationSameId`
    ///   Reserva inválida por tener el mismo ID que otra.
    /// - Parameters:
    ///   - clientList: Lista de clientes.
    ///   - days: Duración de la estancia en el hotel en días.
    ///   - breakfast: Booleano para confirmar si tienen derecho o no a desayuno.
    func addReservation(clientList: [Client], days: Int, breakfast: Bool) throws {
        
        let id: String = assignUniqueId() // asignar ID
        let price: Double = calculatePrice(numClients: UInt8(clientList.count), days: days, breakfast: breakfast)
        
        // Comprobar que ID no coincide
        let identifierChecked: Bool = checkUniqueIdentifier(id: id)
        
        // Comprobar que clientes no coincidan
        let uniqueClientsChecked: Bool = checkUniqueClients(clientList: clientList)
        
        
        //---
        if identifierChecked, uniqueClientsChecked {
            
            containerId.append(id) // Se añade al array donde se almacenan los IDs producidos
            let reservation: Reservation = Reservation(id: id, hotelName: hotelName, clientList: clientList, days: days, price: price, breakfast: breakfast) // Se instancia la reserva
            reservations.append(reservation) // Se añade la reserva al listado de reservas
            print("Reservation successfully saved!")
            print(reservation) // Se devuelve la reserva por consola en formato objeto crudo
            printReservationTicket(reservation: reservation) // Se devuelve por consola en un formato más visual
            
        } else if !identifierChecked, !uniqueClientsChecked {
            
            let errors: [Error] = [ReservationError.reservationSameId, ReservationError.reservationFoundClient]
            throw ReservationError.reservationSameIdAndClient(errors)
            
        }  else if identifierChecked, !uniqueClientsChecked {
            
            throw ReservationError.reservationFoundClient
            
        } else if !identifierChecked, uniqueClientsChecked {
            
            throw ReservationError.reservationSameId
            
        } else {
            
            assertionFailure("ERROR: unique ID and unique client detection does not work correctly.")
            
        }
        
    }
    
    /// Obtiene el listado de todas las reservas actuales.
    func reservationsList() {
        
        var index: Int = 0
        
        print("")
        print("+++++++++++++++++++++++++++++++++++")
        print("++++   List of reservations    ++++")
        print("+++++++++++++++++++++++++++++++++++")
        print("")
        
        for reservation in reservations {
            
            print("+++++++++++++++++++++++++++++++++++")
            print("++++      Reservation \(index + 1)        ++++")
            print("+++++++++++++++++++++++++++++++++++")
            print("+    ID: \(reservation.id)")
            print("+    CLIENTS")
            print("+    -------")
            for indexClient in (0...reservation.clientList.count - 1) {
                print("+      \(indexClient + 1). \(reservation.clientList[indexClient].name)")
            }
            print("+    -------")
            print("+    DAYS: \(reservation.days)")
            print("+    PRICE: \(reservation.price)$")
            switch reservation.breakfast {
            case true:
                print("+    BREAKFAST: YES")
            case false:
                print("+    BREAKFAST: NO")
            }
            print("+++++++++++++++++++++++++++++++++++")
            print("")
            
            index += 1
            
        }
        
    }
    
    /// Cancela la reserva del ID dado como parámetro. Si no existe el ID, lanza un error.
    /// - Throws:
    ///   - `ReservationError.noReservationFound`
    ///   No se encuentra la reserva indicada.
    /// - Parameter id: Identificador único de reserva.
    func cancelReservation(id: String) throws {
        
        // Comprobar que ID no coincide
        let identifierChecked: Bool = checkUniqueIdentifier(id: id)
        
        switch identifierChecked {
        case true:
            throw ReservationError.noReservationFound
        case false:
            /// Índice de la reserva que será posteriormente eliminada.
            let indexReservationForRemoving: Int = indexReservation(id: id) // Búsqueda del índice de la reserva dada por ID
            reservations.remove(at: indexReservationForRemoving) // Se elimina la reserva
            print("Reservation with ID \(id) has been successfully deleted.")
            containerId.remove(at: indexReservationForRemoving) // Se elimina el ID del contenedor de IDs
        }
        
    }
    
    /// Encuentra el índice de la reserva en el listado de reservas para poder, luego, eliminarlo.
    /// - Parameter id: Identificador único de reserva.
    /// - Returns: Devuelve el índice de la reserva a la que pertenece el ID dado como parámetro en el listado de reservas.
    private func indexReservation(id: String) -> Int {
        
        for indexReservation in (0...reservations.count - 1) {
            
            if reservations[indexReservation].id.elementsEqual(id) {
                return indexReservation
            } else {
                continue
            }
            
        }
        
        return -1
        
    }
    
    /// Imprime los detalles completos de una reserva.
    /// - Parameter reservation: `struct` para definir a cualquier reserva del hotel.
    private func printReservationTicket(reservation: Reservation) {
        
        print("+++++++++++++++++++++++++++++++++++")
        print("++++ \(reservation.hotelName.uppercased())  ++++")
        print("+++++++++++++++++++++++++++++++++++")
        print("+       Reservation details       +")
        print("+++++++++++++++++++++++++++++++++++")
        print("+    ID: \(reservation.id)")
        print("+    CLIENTS")
        print("+    -------")
        for indexClient in (0...reservation.clientList.count - 1) {
            print("+      \(indexClient + 1). \(reservation.clientList[indexClient].name)")
        }
        print("+    -------")
        print("+    DAYS: \(reservation.days)")
        print("+    PRICE: \(reservation.price)$")
        switch reservation.breakfast {
        case true:
            print("+    BREAKFAST: YES")
        case false:
            print("+    BREAKFAST: NO")
        }
        print("+++++++++++++++++++++++++++++++++++")
        
    }
    
    /// Comprueba si los clientes dados como parámetro se encuentran ya en cualquier otra reserva almacenada.
    /// - Parameter clientList: Lista de clientes.
    /// - Returns: Devuelve `true` si el cliente no está repetido y `false` si está repetido.
    private func checkUniqueClients(clientList: [Client]) -> Bool {
        
        if !reservations.isEmpty {
            
            for reservation in reservations {
                
                for clientReservation in reservation.clientList {
                    
                    for client in clientList {
                        
                        if clientReservation == client {
                            return false
                        } else {
                            continue
                        }
                        
                    }
                    
                }
                
            }
            
        } else {
            // No hay reservas guardadas todavía
            return true
        }
        
        // Cliente no repetido. Se puede guardar
        return true
        
    }
    
    /// Comprueba si el ID dado como parámetro coincide con cualquier otra reserva almacenada.
    /// - Parameter id: Identificador único de reserva.
    /// - Returns: Devuelve `true` si el ID no coincide y `false` si coincide.
    private func checkUniqueIdentifier(id: String) -> Bool {
        
        if !reservations.isEmpty {
            
            for reservation in reservations {
                
                if reservation.id.elementsEqual(id) {
                    // ID repetido
                    return false
                } else {
                    continue
                }
                
            }
            
        } else {
            // No hay reservas guardadas todavía
            return true
        }
        
        // ID no repetido. Se puede guardar
        return true
        
    }
    
    /// Calcula el precio de la reserva.
    /// - Parameters:
    ///   - numClients: Número de clientes.
    ///   - days: Duración de la estancia en el hotel en días.
    ///   - breakfast: Booleano para confirmar si tienen derecho o no a desayuno.
    /// - Returns: Devuelve el precio de la reserva como `Double`.
    private func calculatePrice(numClients: UInt8, days: Int, breakfast: Bool) -> Double {
        /// Precio base de todas las reservas
        let basePrice: Double = 20.99
        
        switch breakfast {
        case true:
            // precio con desayuno
            return ((Double(numClients) * basePrice * Double(days) * 1.25) * 100).rounded() / 100
        case false:
            // precio sin desayuno
            return ((Double(numClients) * basePrice * Double(days) * 1.00) * 100).rounded() / 100
        }
        
    }
    
    /// Elabora un ID conformado por 5 números, 2 minúsculas y 3 mayúsculas; los cuales son mezclados aleatoriamente para generar un identificador de mayor seguridad. Se comprueba que el ID no haya sido generado previamente contra la lista `containerId`. Si ha sido generado, se vuelve a ejecutar el método.
    /// - Returns: Devuelve el ID como `String`.
    private func assignUniqueId() -> String {
        
        var bucle: Bool = true
        
        while bucle {
            
            // ID -> 5 números + 2 minúsculas + 3 mayúsculas
            var id: String = ""
            
            // generación de los 5 números y adición a la variable id
            for _ in 1...5 {
                
                if let char = UnicodeScalar((49...57).randomElement()!) {
                    let character = Character(char)
                    id.append(character)
                }

            }

            // generación de las 2 minúsculas y adición a la variable id
            for _ in 1...2 {

                if let char = UnicodeScalar((97...121).randomElement()!) {
                    let character = Character(char)
                    id.append(character)
                }

            }

            // generación de las 3 mayúsculas y adición a la variable id
            for _ in 1...3 {

                if let char = UnicodeScalar((65...89).randomElement()!) {
                    let character = Character(char)
                    id.append(character)
                }

            }
            
            /// ID final generado, fruto de la mezcla de los números y letras acumuladas durante el método
            let finalId: String = String(id.shuffled()) // se mezcla el String id (shuffled)
            
            if containerId.contains(finalId) {
                // ID repetido. Se procede a volver a no parar el bucle de producción de ID
                continue
            } else {
                bucle = false
                return finalId
            }
            
        }
        
    }
    
}

//: ### Tests

/// `class` para realizar tests.
class HotelReservationManagerTests {
    /// Instancia de la `class` `HotelReservationManager`
    let hotelReservationManager: HotelReservationManager = HotelReservationManager()
    
    init() {}
    
    /// Test para verificar errores al añadir reservas duplicadas (por ID o si otro cliente ya está en alguna otra reserva) y que nuevas reservas sean añadidas correctamente.
    func testAddReservation() {
        
        // Clientes
        let cliente1: Client = Client(name: "Goku", age: 26, height: 176)
        let cliente2: Client = Client(name: "Vegeta", age: 24, height: 198)
        let cliente3: Client = Client(name: "Son Gohan", age: 39, height: 160)
        let cliente4: Client = Client(name: "Freezer", age: 21, height: 174)
        let cliente5: Client = Client(name: "Piccolo", age: 64, height: 170)
        let cliente6: Client = Client(name: "Trunks", age: 98, height: 173)
        let cliente7: Client = Client(name: "Krilin", age: 27, height: 120)
        let cliente8: Client = Client(name: "Bulma", age: 64, height: 140)
        let cliente9: Client = Client(name: "Goku", age: 80, height: 191)
        
        // Listas de clientes
        let lista1: [Client] = [cliente1, cliente2, cliente3]
        let lista2: [Client] = [cliente4]
        let lista3: [Client] = [cliente5]
        let lista4: [Client] = [cliente6, cliente7]
        let lista5: [Client] = [cliente8]
        let lista6: [Client] = [cliente7]
        let lista7: [Client] = [cliente9]
        
        do {
            // se añade reserva
            try hotelReservationManager.addReservation(clientList: lista1, days: 2, breakfast: true)
            // se comprueba que la lista de reservas tenga 1 reserva
            assert(hotelReservationManager.getReservations().count == 1)
            // se comprueba que se ha guardado correctamente el nombre del primer cliente de la reserva
            assert(hotelReservationManager.getReservations()[0].clientList[0].name.elementsEqual("Goku"), "ERROR: Incorrectly saved client name.")
            // se añade reserva
            try hotelReservationManager.addReservation(clientList: lista2, days: 4, breakfast: false)
            // se comprueba que la lista de reservas tenga 2 reservas
            assert(hotelReservationManager.getReservations().count == 2)
            // se comprueba que se ha guardado correctamente la edad del primer cliente de la segunda reserva
            assert(hotelReservationManager.getReservations()[1].clientList[0].age == 21, "ERROR: Client's age incorrectly stored.")
            // se añade reserva
            try hotelReservationManager.addReservation(clientList: lista3, days: 3, breakfast: true)
            // se comprueba que la lista de reservas tenga 3 reservas
            assert(hotelReservationManager.getReservations().count == 3)
            // se comprueba que se ha guardado correctamente la altura del primer cliente de la tercera reserva
            assert(hotelReservationManager.getReservations()[2].clientList[0].height == 170, "ERROR: Incorrectly stored client height.")
            // se añade reserva
            try hotelReservationManager.addReservation(clientList: lista4, days: 6, breakfast: true)
            // se comprueba que la lista de reservas tenga 4 reservas
            assert(hotelReservationManager.getReservations().count == 4)
            // se comprueba que se ha guardado correctamente la duración de la estancia de la cuarta reserva
            assert(hotelReservationManager.getReservations()[3].days == 6, "ERROR: Wrong days of stay stored in the reservation.")
            // se añade reserva
            try hotelReservationManager.addReservation(clientList: lista5, days: 3, breakfast: false)
            // se comprueba que la lista de reservas tenga 5 reservas
            assert(hotelReservationManager.getReservations().count == 5)
            // se comprueba que se ha guardado correctamente que la quinta reserva no tiene desayuno
            assert(hotelReservationManager.getReservations()[4].breakfast == false, "ERROR: Wrong Boolean for breakfast stored in reserve.")
            // se comprueba que se ha guardado correctamente el precio de la quinta reserva
            assert(hotelReservationManager.getReservations()[4].price == 62.97, "ERROR: Wrong reservation price.")
            // se añade reserva con un cliente de igual nombre que uno guardado en reservas pero de diferente edad y altura, por ejemplo. Determinante el protocolo Equatable del struct
            try hotelReservationManager.addReservation(clientList: lista7, days: 5, breakfast: true)
            // se añade reserva pero con cliente repetido, por lo que tiene que lanzar el error ReservationError.reservationFoundClient y no añadir la reserva
            try hotelReservationManager.addReservation(clientList: lista6, days: 3, breakfast: true)
        } catch let ReservationError.reservationSameIdAndClient(errors) {
            // Manejar múltiples errores individuales
            for error in errors {
                print(error)
            }
        } catch let error {
            // Manejar el resto de errores
            print(error.localizedDescription)
        }
        
    }
    
    /// Test para verificar que las reservas se cancelen correctamente y que cancelar una reserva no existente resulte en un error.
    func testCancelReservation() {
        /// Número de reservas previo a la posterior eliminación de una reserva para test.
        let numReservations: Int = hotelReservationManager.getReservations().count
        
        do {
            // se comprueba que la lista de reservas siga teniendo 6 reservas, ya que previamente se lanzó error por repetir cliente
            assert(hotelReservationManager.getReservations().count == 6)
            // se cancela la primera reserva hecha anteriormente
            try hotelReservationManager.cancelReservation(id: hotelReservationManager.getContainerId()[0])
            // se comprueba que el número de reservas se haya reducido en uno
            assert(hotelReservationManager.getReservations().count == numReservations - 1, "ERROR: The reservation has not been deleted properly.")
            // se cancela una reserva con un ID inexistente, por lo que debe lanzar el error ReservationError.noReservationFound
            try hotelReservationManager.cancelReservation(id: "Vinícius")
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    /// Test para asegurar que el sistema calcula los precios de forma consistente.
    func testReservationPrice() {
        
        // Clientes
        let cliente1: Client = Client(name: "Majin Boo", age: 26, height: 176)
        let cliente2: Client = Client(name: "Broly", age: 24, height: 155)
        let cliente3: Client = Client(name: "Cell", age: 27, height: 178)
        let cliente4: Client = Client(name: "Mr. Satán", age: 27, height: 174)
        let cliente5: Client = Client(name: "Androide 18", age: 124, height: 170)
        let cliente6: Client = Client(name: "Chi-Chi", age: 19, height: 155)
        
        // Listas de clientes
        let lista1: [Client] = [cliente1, cliente2, cliente3]
        let lista2: [Client] = [cliente4, cliente5, cliente6]
        
        do {
            // se añaden dos reservas con los mismos parámetros para comprobar que el precio generado sea idéntico, corroborando la consistencia
            try hotelReservationManager.addReservation(clientList: lista1, days: 4, breakfast: true)
            try hotelReservationManager.addReservation(clientList: lista2, days: 4, breakfast: true)
            // se comprueba que los dos precios sean idénticos
            assert(hotelReservationManager.getReservations()[hotelReservationManager.getReservations().count - 1].price.isEqual(to: hotelReservationManager.getReservations()[hotelReservationManager.getReservations().count - 2].price), "ERROR: The price is not the same for both reservations.")
        } catch let ReservationError.reservationSameIdAndClient(errors) {
            // Manejar múltiples errores individuales
            for error in errors {
                print(error)
            }
        } catch let error {
            // Manejar el resto de errores
            print(error.localizedDescription)
        }
        
    }
    
}

let hotelReservationManagerTests: HotelReservationManagerTests = HotelReservationManagerTests()

hotelReservationManagerTests.testAddReservation()
print("\n---\n")

hotelReservationManagerTests.testCancelReservation()
print("\n---\n")

hotelReservationManagerTests.testReservationPrice()
print("\n---")

// impresión de la lista de reservas actuales
hotelReservationManagerTests.hotelReservationManager.reservationsList()

