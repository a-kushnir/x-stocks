# frozen_string_literal: true

class Pagy
  module Frontend
    # Overrides Pagy Frontend methods
    module Override
      def pagy_nav(pagy, pagy_id: nil, link_extra: '', **vars)
        p_id   = %( id="#{pagy_id}") if pagy_id
        link   = pagy_link_proc(pagy, link_extra: link_extra)
        p_prev = pagy.prev
        p_next = pagy.next
        t_prev = "#{inline_svg('svg/chevron-left', size: '24*24')} Previous" # pagy_t('pagy.nav.prev')
        t_next = "Next #{inline_svg('svg/chevron-right', size: '24*24')}" # pagy_t('pagy.nav.next')

        html = +%(<nav#{p_id} class="pagy-nav pagination" aria-label="pager">)
        html << if p_prev
                  %(<span class="page prev">#{link.call p_prev, t_prev, 'aria-label="previous"'}</span>)
                else
                  %(<span class="page prev disabled">#{t_prev}</span>)
                end
        pagy.series(**vars).each do |item| # series example: [1, :gap, 7, 8, "9", 10, 11, :gap, 36]
          html << case item
                  when Integer then %(<span class="page">#{link.call item}</span>)
                  when String  then %(<span class="page active">#{pagy.label_for(item)}</span>)
                  when :gap    then %(<span class="page gap">#{pagy_t('pagy.nav.gap')}</span>)
                  else raise InternalError, "expected item types in series to be Integer, String or :gap; got #{item.inspect}"
                  end
        end
        html << if p_next
                  %(<span class="page next">#{link.call p_next, t_next, 'aria-label="next"'}</span>)
                else
                  %(<span class="page next disabled">#{t_next}</span>)
                end
        html << %(</nav>)
      end
    end
  end
end
