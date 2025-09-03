# frozen_string_literal: true

module Logistics
  # -----------------------------------------------------------
  # ThreeOpt:
  #  - Recibe una ruta y realiza intercambios de 3-opt
  #    (cortar en 3 puntos y recombinar segmentos).
  #  - Itera por i<j<k; si encuentra una variante con menor costo,
  #    la acepta y continúa hasta que ya no mejora.
  # -----------------------------------------------------------
  class ThreeOpt
    def initialize(planner)
      @planner = planner  # para usar @planner.cost(route)
    end

    # max_passes: cuántas veces re-correr todo el espacio de (i,j,k)
    def improve(route, max_passes: 2)
      best      = route.dup
      best_cost = cost(best)
      passes    = 0

      while passes < max_passes
        improved = false

        # i, j, k marcan cortes A|B|C|D (no tocamos extremos "E")
        (1...(best.length - 4)).each do |i|
          (i + 2...(best.length - 2)).each do |j|
            (j + 2...(best.length - 1)).each do |k|
              variants(best, i, j, k).each do |cand|
                c = cost(cand)
                if c < best_cost
                  best      = cand
                  best_cost = c
                  improved  = true
                end
              end
            end
          end
        end

        break unless improved    # si no mejora, cortamos
        passes += 1
      end

      best
    end

    private

    def cost(route) = @planner.cost(route)

    # Genera combinaciones típicas de 3-opt:
    # A = 0..i-1, B = i..j-1, C = j..k-1, D = k..fin
    # probamos reversiones e intercambios de B y C
    def variants(r, i, j, k)
      a = r[0...i]
      b = r[i...j]
      c = r[j...k]
      d = r[k..-1]

      [
        a + b + c + d,                      # original
        a + b.reverse + c + d,
        a + b + c.reverse + d,
        a + b.reverse + c.reverse + d,
        a + c + b + d,                      # intercambio B <-> C
        a + c.reverse + b + d,
        a + c + b.reverse + d,
        a + c.reverse + b.reverse + d
      ].uniq
    end
  end
end
