import Pkg; Pkg.activate(@__DIR__)
using Limace
using CairoMakie
using CatppuccinMakieThemes


themes = (CatppuccinMakieThemes.latte, CatppuccinMakieThemes.mocha)

for theme in themes
	_theme = CatppuccinMakieThemes.theme(theme)
	CairoMakie.set_theme!(_theme)


	let 
		b = Insulating(5) #defines the basis
		l,m = 1,0
		S(l,n) = r->Limace.s(b, l,m,n,r) #access the poloidal scalar function (identical for all m)
		
		f = Figure(size=(500,300))
		ax = Axis(f[1,1], xlabel=L"r", ylabel=L"S_{ln}(r)")
		xlims!(ax,0,1)
		for n in 1:b.N
			lines!(ax,0..1,S(l,n), linewidth=2)
		end
		save(joinpath(@__DIR__,"../figs/magfield_part1_sln_$(theme.name).png"), f)

		T(l,n) = r->Limace.t(b, l,m,n,r) #access the poloidal scalar function (identical for all m)
		f = Figure(size=(500,300))
		ax = Axis(f[1,1], xlabel=L"r", ylabel=L"T_{ln}(r)")
		xlims!(ax,0,1)
		for n in 1:b.N
			lines!(ax,0..1,T(l,n), linewidth=2)
		end
		save(joinpath(@__DIR__,"../figs/magfield_part1_tln_$(theme.name).png"), f)
	end

	#part2
	
	div_colormap = theme == CatppuccinMakieThemes.latte ? :vik : :berlin
	let
		using Limace.Discretization: discretize
		N = 5
		b = Insulating(N)

		l,m,n = 1,0,1 # spherical harmonic degree l and order m , and radial degree n.
		factor = 1.0 # amplitude or factor of the component

		B_p_101 = BasisElement(b, Poloidal, (l,m,n), factor)

		nr,nθ = 50,50
		r = range(1e-9,2,length=nr)
		θ = range(0,π,length=nθ)
		x = r .* sin.(θ')
		y = r .* cos.(θ')

		ϕ = 0.0
		B_disc = [discretize(B_p_101, r, θ, ϕ) for r in r, θ in θ]
		Br = real.(getindex.(B_disc,1))
		
		f = Figure(size=(500,500))
		ax = Axis(f[1,1], aspect=DataAspect())
		hidespines!(ax)
		hidedecorations!(ax)
		clim = maximum(abs,Br)
		surface!(ax, x, y, Br, colormap=div_colormap, colorrange=(-clim,clim), shading=NoShading)
		lines!(ax, sin.(θ), cos.(θ), color=_theme.textcolor, linestyle=:dash, linewidth=1)
		save(joinpath(@__DIR__,"../figs/magfield_part2_br_$(theme.name).png"), f)
	end


end