import PyPlot

for p in [:plot, :semilogx, :semilogy, :loglog]
    q = Expr(:., :PyPlot, QuoteNode(p))
    fn = quote
        function $q(trs::Vector{TestResults}, args...; xfield::Symbol=:scd, yfield::Symbol=:walltime,
                    xunit="", yunit="(s)")
            x = getfield_vec(trs, xfield)
            y = getfield_vec(trs, yfield)
            $q(x,y, args...)
            PyPlot.xlabel(string(xfield)*" "*xunit)
            PyPlot.ylabel(string(yfield)*" "*yunit)
        end
    end

    eval(fn)
end
