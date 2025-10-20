module taxidrivervc::taxidrivervc {
    // Importa UID para identificación única de objetos
    use sui::object::UID;
    // Importa el contexto de transacción para crear objetos y obtener el sender
    use sui::tx_context::TxContext;
    // Importa cadena de texto para campos de texto
    use std::string::String;
    // Importa funciones para transferir propiedad de objetos
    use sui::transfer;
    use sui::tx_context;

    // --- ESTRUCTURAS ---

    // TarifaBase: Objeto singleton con tarifas fijas
    // 'has key, store' indica que es un objeto global con clave única
    public struct TarifaBase has key, store {
        // ID único global del objeto TarifaBase
        id: UID,
        // Costo por kilómetro
        costo_km: u64,
        // Cuota máxima estimada por casetas
        cuota_caseta_max: u64,
    }

    // TicketServicio: Ticket inmutable que se transfiere al cliente
    // Contiene detalles del viaje y método de pago
    public struct TicketServicio has key, store {
        // Identificador único del ticket
        id: UID,
        // Costo total final del viaje
        costo_final: u64,
        // Destino del viaje
        destino: String,
        // Identificación del conductor
        conductor_id: String,
        // Número de unidad asignada del taxi
        num_unidad: u64,
        // Indica si el pago es en efectivo (true) o tarjeta (false)
        es_efectivo: bool,
    }

    // AdminCap: Capacidad para administrar tarifas
    // Solo el poseedor puede modificar tarifas
    public struct AdminCap has key {
        id: UID,
    }

    // --- FUNCIONES ---

    // Función interna para inicializar la tarifa base y el administrador
    fun init(ctx: &mut TxContext) {
        // Crea un nuevo UID para la tarifa
        let tarifa_id = object::new(ctx);
        // Construye la tarifa base con valores predeterminados
        let tarifa = TarifaBase {
            id: tarifa_id,
            costo_km: 10,
            cuota_caseta_max: 50,
        };
        // Transfiere la tarifa al emisor de la transacción para que sea global
        transfer::transfer(tarifa, tx_context::sender(ctx));

        // Crea un UID para el administrador
        let admin_id = object::new(ctx);
        // Construye el AdminCap para control exclusivo
        let admin = AdminCap {
            id: admin_id,
        };
        // Transfiere la capacidad de administrador al emisor
        transfer::transfer(admin, tx_context::sender(ctx));
    }

    // Permite al administrador actualizar las tarifas
    public fun actualizar_tarifa(admin: &AdminCap, tarifa: &mut TarifaBase, nuevo_costo_km: u64, nueva_cuota_caseta_max: u64) {
        tarifa.costo_km = nuevo_costo_km;
        tarifa.cuota_caseta_max = nueva_cuota_caseta_max;
    }

    // Permite emitir un ticket de servicio y transferirlo al usuario
    #[allow(lint(self_transfer))]
    public fun emitir_ticket(
        costo_final: u64,
        destino: String,
        conductor_id: String,
        num_unidad: u64,
        es_efectivo: bool,
        ctx: &mut TxContext
    ) {
        // Validación simple: costo debe ser mayor a 0
        assert!(costo_final > 0, 1);

        // Crea un nuevo UID para el ticket
        let ticket_id = object::new(ctx);
        // Construye el ticket con la información proporcionada
        let ticket = TicketServicio {
            id: ticket_id,
            costo_final,
            destino,
            conductor_id,
            num_unidad,
            es_efectivo,
        };
        // Transfiere el ticket al emisor de la transacción (cliente)
        transfer::transfer(ticket, tx_context::sender(ctx));
    }
}