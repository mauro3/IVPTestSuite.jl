# HIRES (chemical reaction, mildly stiff)
#
# http://www.dm.uniba.it/~testset/problems/hires.php
# http://www.unige.ch/~hairer/testset/testset.html
#
## Copyright (C) 2014, Mauro Werder <mauro_lc@runbox.com>
#
# Adapted from OdePkg, original author:
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


export hires

hires = let
    tcname = :hires
    T = Float64
    Tarr = Matrix
    dae = 0
    dof = 8

    # Computes the results for the HIRES problem
    function fn!(t, y, out)
        out[1] = -1.71 * y[1] + 0.43 * y[2] + 8.32 * y[3] + 0.0007
        out[2] =  1.71 * y[1] - 8.75 * y[2]
        out[3] = -10.03 * y[3] + 0.43 * y[4] + 0.035 * y[5]
        out[4] =  8.32 * y[2] + 1.71 * y[3] - 1.12 * y[4]
        out[5] = -1.745 * y[5] + 0.43 * (y[6] + y[7])
        out[6] = -280 * y[6] * y[8] + 0.69 * y[4] + 1.71 * y[5] - 0.43 * y[6] + 0.69 * y[7]
        out[7] =  280 * y[6] * y[8] - 1.81 * y[7]
        out[8] = -out[7]
        return nothing
    end
    # initializes storage for y:
    fn!(;T_::Type=T, dof_=dof) = zeros(T_,dof_)        
    
    # Computes the JACOBIAN matrix for the HIRES problem
    function jac!(t, y, dfdy)
        dfdy[1,1] = -1.71
        dfdy[1,2] =  0.43
        dfdy[1,3] =  8.32
        dfdy[2,1] =  1.71
        dfdy[2,2] = -8.75
        dfdy[3,3] = -10.03
        dfdy[3,4] =  0.43
        dfdy[3,5] =  0.035
        dfdy[4,2] =  8.32
        dfdy[4,3] =  1.71
        dfdy[4,4] = -1.12
        dfdy[5,5] = -1.745
        dfdy[5,6] =  0.43
        dfdy[5,7] =  0.43
        dfdy[6,4] =  0.69
        dfdy[6,5] =  1.71
        dfdy[6,6] = -280 * y[8] - 0.43
        dfdy[6,7] =  0.69
        dfdy[6,8] = -280 * y[6]
        dfdy[7,6] =  280 * y[8]
        dfdy[7,7] = -1.81
        dfdy[7,8] =  280 * y[6]
        dfdy[8,6] = -280 * y[8]
        dfdy[8,7] =  1.81
        dfdy[8,8] = -280 * y[6]
        return nothing
    end
    # Returns a matrix which can hold the Jacobian of selected
    # type, initialized to zero.  Can also be used to make a
    # Matlab-style JPattern matrix with jac!(Bool)
    jac!(;T_::Type=T, dof_=dof) = zeros(T_,dof_,dof_)
    
    mass! = nothing
    
    ic = T[1, 0, 0, 0, 0, 0, 0, 0.0057]
    tspan = T[0.0, 321.8122]
    
    refsol = zeros(T, dof)
    refsol[1] = 0.73713125733256e-3
    refsol[2] = 0.14424857263161e-3
    refsol[3] = 0.58887297409675e-4
    refsol[4] = 0.11756513432831e-2
    refsol[5] = 0.23863561988313e-2
    refsol[6] = 0.62389682527427e-2
    refsol[7] = 0.28499983951857e-2
    refsol[8] = 0.28500016048142e-2

    refsolinds = trues(dof)

    scd_absinds = Int[]
    
    tc = TestCaseExplicit{tcname, T, Tarr}(
                             mildlystiff,
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
    tc_stiff[tcname] = tc
end

