# This IVP is a stiff system of 6 non-linear Differential Algebraic
# Equations of index 1. The problem originates from Akzo Nobel Central
# research in Arnhern, The Netherlands, and describes a chemical
# process in which 2 species are mixed, while carbon dioxide is
# continuously added. From:
#
# http://www.dm.uniba.it/~testset/problems/chemakzo.php

# Code adapted from odepkg:
## Copyright (C) 2007-2012, Thomas Treichl <treichl@users.sourceforge.net>
## OdePkg - A package for solving ordinary differential equations and more
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

export chemakzo

chemakzo = let
    tcname = :chemakzo
    T = Float64 # the datatype used
    Tarr = Matrix
    dof = 6 # degrees of freedom
    dae=1
    # stiffness of system, one of the three constants
    stiffness = [nonstiff, mildlystiff, stiff][3]

    # some constants
    k1   = 18.7; k2  = 0.58; k3 = 0.09;   k4  = 0.42;
    kbig = 34.4; kla = 3.3;  ks = 115.83; po2 = 0.9;
    hen  = 737.0
    
    function fn!(t,y,dydt)
        r1  = k1 * y[1]^4 * sqrt(y[2])
        r2  = k2 * y[3] * y[4]
        r3  = k2 / kbig * y[1] * y[5]
        r4  = k3 * y[1] * y[4]^2
        r5  = k4 * y[6]^2 * sqrt(y[2])
        fin = kla * (po2 / hen - y[2])
        dydt[:] = [-2 * r1 + r2 - r3 - r4,
                   -0.5 * r1 - r4 - 0.5 * r5 + fin,
                   r1 - r2 + r3,
                   - r2 + r3 - 2 * r4,
                   r2 - r3 + r5,
                   ks * y[1] * y[4] - y[6]]
        return nothing
    end
    # initializes storage for y:
    fn!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_)

    function jac!(t,y, dfdy)
        # the Jacobian of f
        #
        # Set to nothing if it is not known

        r11  = 4 * k1 * y[1]^3 * sqrt(y[2])
        r12  = 0.5 * k1 * y[1]^4 / sqrt(y[2])
        r23  = k2 * y[4]
        r24  = k2 * y[3]
        r31  = (k2 / kbig) * y[5]
        r35  = (k2 / kbig) * y[1]
        r41  = k3 * y[4]^2
        r44  = 2 * k3 * y[1] * y[4]
        r52  = 0.5 * k4 * y[6]^2 / sqrt(y[2])
        r56  = 2 * k4 * y[6] * sqrt(y[2])
        fin2 = -kla
        
        dfdy[1,1] = -2 * r11 - r31 - r41
        dfdy[1,2] = -2 * r12
        dfdy[1,3] = r23
        dfdy[1,4] = r24 - r44
        dfdy[1,5] = -r35
        dfdy[2,1] = -0.5 * r11 - r41
        dfdy[2,2] = -0.5 * r12 - 0.5 * r52 + fin2
        dfdy[2,4] = -r44
        dfdy[2,6] = -0.5 * r56
        dfdy[3,1] = r11 + r31
        dfdy[3,2] = r12
        dfdy[3,3] = -r23
        dfdy[3,4] = -r24
        dfdy[3,5] = r35
        dfdy[4,1] = r31 - 2 * r41
        dfdy[4,3] = -r23
        dfdy[4,4] = -r24 - 2 * r44
        dfdy[4,5] = r35
        dfdy[5,1] = -r31
        dfdy[5,2] = r52
        dfdy[5,3] = r23
        dfdy[5,4] = r24
        dfdy[5,5] = -r35
        dfdy[5,6] = r56
        dfdy[6,1] = ks * y[4]
        dfdy[6,4] = ks * y[1]
        dfdy[6,6] = -1
        return nothing
    end
    jac!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)  

    function mass!(t, y, m)
        m[:] =  eye(T,dof)
        m[6,6] = 0.0
        return nothing
    end
    mass!( ; T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_) 
    
    ic = T[0.444, 0.00123, 0, 0.007, 0, ks * 0.444 * 0.007] # vector of initial conditions
    tspan = T[0, 180] # integration interval
    refsol =     T[0.11507949206617e+0, 0.12038314715677e-2,
                   0.16115628874079e+0, 0.36561564212492e-3,
                   0.17080108852644e-1, 0.48735313103074e-2]  # reference solution at tspan[2]
    refsolinds = trues(dof)

    scd_absinds = falses(dof)
    tc = TestCaseExplicit{tcname, T, Tarr}(
                             stiffness,
                             dae,
                             dof,
                             fn!,
                             jac!,
                             mass!,
                             ic,
                             tspan,
                             refsol,
                             refsolinds,
                             scd_absinds)
    tc_all[tcname] = tc
    tc_dae[tcname] = tc
    tc_dae1[tcname] = tc
end
    
