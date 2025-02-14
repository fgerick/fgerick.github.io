+++
title = "Magnetic field visualization. I. Theory and setup"
hasmath = true
hascode = true
layout = "post"
date = Date(2025, 2, 14)
postheader="/assets/figs/postheader_magfield_theory.png"
+++

# {{title}}

Geophysicists like to speak about Earth's magnetic field in terms of spherical harmonic degrees $l$ and orders $m$, in internal and external, toroidal and poloidal components.
Sometimes, it is nice to come back to the actual shape of the magnetic field and to visualize it in space to get some intuition on what we are actually discussing.

Here, I will outline how to visualize components of the magnetic field $\vec{B}$ used to model waves internal to the Earth's core using the [Limace.jl](https://github.com/fgerick/Limace.jl) package.

For a reminder, I will start with the very technical description of the magnetic field for the unfamiliar reader. For a (much) more rigorous and detailed description of the theoretical aspects of the geomagnetic field, I refer to \citeT{backus_foundations_1996}.


## Theoretical description of the magnetic field

The magnetic field $\vec{B}$ can be described by two scalar functions $P$ and $T$, known as the poloidal and toroidal scalars, so that
$$
\vec{B} = \boldsymbol{\nabla}\times\boldsymbol{\nabla}\times P\vec{r} + \boldsymbol{\nabla}\times T\vec{r},
$$
where $\vec{r}=r\vec{e}_r$ with the radius $r$ and the unit vector in the radial direction $\vec{e}_r$, for spherical coordinates $(r,\theta,\phi)$.
This is a consequence of not allowing for magnetic monopoles ($\boldsymbol{\nabla}\boldsymbol{\cdot}\vec{B}=0$). 

These scalars $P,T$ are commonly further separated into radial functions $P_n(r), T_n(r)$ and the spherical harmonics $Y_l^m(\theta,\phi)$, so that 
$$
P = \sum_{lmn} \alpha_{lmn} P_n(r) Y_l^m(\theta,\phi),\\
T = \sum_{lmn} \beta_{lmn} T_n(r) Y_l^m(\theta,\phi),
$$
where $\alpha_{lmn}$ and $\beta_{lmn}$ are scalar coefficients determining the amplitude of each component.

So far, we have not distinguished between regions that are electrically conducting or assumed insulating. 
For simplicity, let us assume that only the core of the Earth is conducting and everything above (mantle, crust, ionosphere and magnetosphere) is electrically insulating.
Then, we can separate our description of the magnetic field into two regions, one interior and one exterior to the core.
In the insulating exterior, $r>1$ (for the radius of the core fixed to $r=1$), the magnetic field must satisfy
$$
\boldsymbol{\nabla}\times\vec{B} = \vec{0}, \quad \text{at }\, r>1.
$$
i.e. no current. This condition translates to 
$$
\vec{B} = -\nabla \Phi, \quad \text{at }\, r>1.
$$
Since $\boldsymbol{\nabla}\boldsymbol{\cdot}\vec{B}=0$, we require $\nabla^2 \Phi = 0$ so that $\Phi \sim l P_n(1)r^{-(l+1)}Y_l^m$.
The required continuity of the magnetic field from the interior to the exterior is equivalent to boundary conditions at $r=1$:
$$
T_n(1) = 0,\\
\frac{\partial P_n(r)}{\partial r}\bigg|_{r=1} + (l+1)P_n(1) = 0.\label{eq:bc}
$$
In addition, the description in the interior down to $r=0$ requires that the radial functions require a regularity condition \citeP{livermore_spectral_2007}, namely $P_n,T_n \sim r^l f(r^2)$.
What remains to be defined are the radial functions $P_n,T_n$, subject to the boundary conditions \eqref{eq:bc}.

Examples of functions based on Jacobi polynomials $J_n^{(a,b)}(x)$ can be found in \citeT{li_optimal_2010} and \citeT{gerick_interannual_2024}.
We shall focus here on the latter, as this is the basis implemented in `Limace.jl`.

Poloidal and toroidal scalars satisfying the insulating boundary conditions \eqref{eq:bc} are given by
$$
\begin{align*}
S_{ln} &= f_s r^l\sum_{k=0}^{2}(-1)^k(1+\delta_{k1})(2l+4n+2k-3)J_{n-k}^{(0,l+1/2)}\left(2r^2{-}1\right), \label{eq:Sln} \\
T_{ln} &= f_t r^l\left(J_{n}^{(0,l+1/2)}\left(2r^2{-}1\right) - J_{n-1}^{(0,l+1/2)}\left(2r^2{-}1\right)\right).
\end{align*}
$$
with the normalization factors
$$
\begin{align*}
f_s &= \left(2l(l+1)(2l+4n-3)(2l+4n-1)(2l+4n+1)\right)^{-1/2},\\
f_t &= \left(\frac{(2l+4n-1)(2l+4n+3)}{2l(l+1)(2l+4n+1)}\right)^{1/2}.
\end{align*}
$$

The definition of a basis of poloidal and toroidal field vectors for a magnetic field in a full sphere, satisfying the insulating boundary condition at $r=1$ is hereby complete.
We can now move on to the visualization of components of this magnetic field within the [Limace.jl](https://github.com/fgerick/Limace.jl) package.

## Magnetic field components in Limace.jl

Let us now visualize some of these scalar functions using [Limace.jl](https://github.com/fgerick/Limace.jl). 
First, we need to set up our working environment, if we don't have one already available. 

\collapse{See details on installing `Limace.jl` and a plotting library (`Makie`)}{

If not already done, [install Julia](https://julialang.org/downloads/), preferrably `v1.10` (current `lts`) or upwards. 
I recommend using `juliaup`, as instructed.

Once Julia is installed, we can install [Limace.jl](https://github.com/fgerick/Limace.jl):
```julia
import Pkg; Pkg.add(url="https://github.com/fgerick/Limace.jl.git")
```

Or, if you want to do so in a local environment, `cd` into the folder of your environment and run

```julia
Pkg.activate(".")
```
before running ``Pkg.add``.

After this, we are ready to use `Limace.jl`, but we still need to install some plotting library.
We will use [Makie.jl](https://github.com/MakieOrg/Makie.jl), which comes with different backends (`CairoMakie.jl`, `WGLMakie.jl` and `GLMakie.jl`).
Let's install `CairoMakie.jl` and `WGLMakie.jl` for now, as these are convenient for static images and websites/notebooks. 
This is straightforward, as these packages are registered in the `General` package registry of Julia:

```julia
Pkg.add(["CairoMakie"; "WGLMakie"])
```

Installation and precompilation of these packages can take a while, which is normal.

When everything is done, you should be able to load the desired packages:
```julia
using Limace
using CairoMakie
```
}

With the environment set up, we are ready to visualize some of the scalar functions defined in \eqref{eq:Sln}. 
For example, the first few degrees $S_{11}(r),...,S_{15}(r)$ are plotted as

```julia
using Limace
using CairoMakie

b = Insulating(5) #defines the basis
l,m = 1,0
S(l,n) = r->Limace.s(b, l,m,n,r) #access the poloidal scalar function (identical for all m)

f = Figure(size=(500,300))
ax = Axis(f[1,1], xlabel=L"r", ylabel=L"S_{ln}(r)")
xlims!(ax,0,1)
for n in 1:b.N
	lines!(ax,0..1,S(l,n), linewidth=2)
end
f
```

{{figurelightdark figs/magfield_part1_sln_Latte.png figs/magfield_part1_sln_Mocha.png}}

It is interesting to note here, that only the $n=1$ degree has a non-zero component at $r=1$. Therefore, only this single degree contributes to the magnetic field observable outside of the core.
By definition, all $T_{ln}(1)=0$.

```julia
T(l,n) = r->Limace.t(b, l,m,n,r) #access the poloidal scalar function (identical for all m)

f = Figure(size=(500,300))
ax = Axis(f[1,1], xlabel=L"r", ylabel=L"T_{ln}(r)")
xlims!(ax,0,1)
for n in 1:b.N
	lines!(ax,0..1,T(l,n), linewidth=2)
end
f
```

{{figurelightdark figs/magfield_part1_tln_Latte.png figs/magfield_part1_tln_Mocha.png}}


## Summary
We have recalled the definition of a magnetic field basis in terms of poloidal and toroidal components, including the definition of the scalar functions $P$ and $T$.
One defintion of these scalar function, implemented in `Limace.jl` was outlined and we have setup our Julia environment to use `Limace.jl` and `CairoMakie.jl` to visualize a few degrees of the scalar functions. 
From here, we are in the position to visualize the actual magnetic field.

<!-- [Go to Part II of the series.](/posts/2025-02-14-magnetic-fields-part2) -->


## References
\bibliography{}
<!-- {{bibliography}} -->


[go back](..)