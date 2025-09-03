class LogisticController < ApplicationController
  # API-only: no usamos CSRF ni sesiones

  def route
    # (A) Leer y normalizar la entrada:
    #     se puede aceptar un string "P1, P3, P4"  o un Array ["P1","P3","P4"] (array)
    items = normalize_items(params[:items])

    # (B) Validación si no hay Items
    return render json: { error: "items es requerido" }, status: 422 if items.empty?

    # (C) Crear el planificador y ejecutar 3-opt
    planner = Logistics::RoutePlanner.new
    result  = planner.compute(items: items)     # repuesta del algoritmo 3-OPT

    # (D) Construir ayudas para el Voting:
    #     - visit_order_str: fácil de comparar como string en el voter
    #     - hash: SHA256 del string (si prefieren comparar por hash)
    order_str = result[:visit_order].join(">")

    # (E) Respuesta del calculo del algoritmo
    render json: {
      visit_order:     result[:visit_order],    # array: ["E","P10",...,"E"]
      visit_order_str: order_str,               # string: "E>P10>...>E"
      cost:            result[:cost],           # número
      hash:            Digest::SHA256.hexdigest(order_str)
    }, status: 200

  rescue Logistics::UnknownNodeError, ArgumentError => e
    # (F) Errores de validación: nodo inválido o matriz mala
    render json: { error: e.message }, status: 422
  end

  private

  # normaliza ITEMS
  def normalize_items(raw)
    return [] if raw.nil?
    return raw if raw.is_a?(Array)
    raw.to_s.split(",").map(&:strip).reject(&:blank?)
  end
end
