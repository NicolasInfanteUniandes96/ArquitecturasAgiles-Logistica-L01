# frozen_string_literal: true
require 'json'

module Logistics
  # Error específico si llega un producto inexistente
  class UnknownNodeError < StandardError; end

  # -----------------------------------------------------------
  # RoutePlanner:
  #  - Carga la matriz desde JSON (nodes + matrix).
  #  - Valida items.
  #  - Construye una ruta inicial *trivial* (E + items + E).
  #  - Aplica 3-opt *puro* (sin NN/2-opt) para mejorar la ruta.
  #  - Devuelve la mejor ruta y su costo.
  # -----------------------------------------------------------
  class RoutePlanner
    def initialize(json_path: Rails.root.join("config", "warehouse_graph.json"))
      # 1) Leer archivo JSON
      data   = JSON.parse(File.read(json_path))

      # 2) Nombres de nodos y su índice en la matriz
      @nodes = data["nodes"]                                  # ["E","P1",...,"P18"]
      @index = @nodes.each_with_index.to_h                    # {"E"=>0,"P1"=>1,...}

      # 3) Matriz NxN de costos mínimos entre todos los nodos
      @dist  = data["matrix"]

      # 4) Validación de dimensiones
      n = @nodes.size
      raise ArgumentError, "matrix inválida" unless @dist.is_a?(Array) && @dist.size == n && @dist.all? { |r| r.size == n }
    end

    # Método principal: recibe items, aplica 3-opt, devuelve ruta/costo
    def compute(items:)
      # 5) Validar que cada item exista en nodes (si no, levantamos error)
      items.each { |p| raise UnknownNodeError, "Nodo desconocido: #{p}" unless @nodes.include?(p) }

      # 6) Quitar duplicados por si acaso
      items = items.uniq

      # 7) Ruta inicial (3-opt puro):
      #    empezamos en E, visitamos los items en el orden recibido y volvemos a E.
      initial = ["E"] + items + ["E"]

      # 8) Mejoramos la ruta con 3-opt (2 pasadas suele bastar para 10–20 nodos)
      best = ThreeOpt.new(self).improve(initial, max_passes: 2)

      # 9) Empaquetamos resultado
      { visit_order: best, cost: cost(best)}
    end

    # -------------------- Helpers de costo --------------------

    # Calcula costo total de una ruta sumando cada salto consecutivo
    def cost(route)
      route.each_cons(2).sum { |a, b| cost_between(a, b) }
    end

    # Costo O(1) entre dos nodos usando la matriz
    def cost_between(a, b)
      return 0 if a == b
      @dist[@index[a]][@index[b]]
    end
  end
end
