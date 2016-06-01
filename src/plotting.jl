using Winston

for p in [:plot, :semilogx, :semilogy, :loglog, :oplot]
    q = Expr(:., :Winston, QuoteNode(p))
    fn = quote
        function $q(trs::Vector{TestResults}, xfield::Symbol, yfield::Symbol, args...;
                    xunit="", yunit="")
            x = getfield_vec(trs, xfield)
            y = getfield_vec(trs, yfield)
            $q(x,y, args...)
            xlabel(string(xfield)*" "*xunit)
            ylabel(string(yfield)*" "*yunit)
        end
    end
    @show fn
    eval(fn)
end


function Winston.plot(r::TestResults; relerr=false)
    if relerr

        plot(relerror(r))
    else
        plot(r.solution)
    end
end
