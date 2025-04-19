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
		rmax = 2.0  #we can discretize at r>1 for this poloidal field.
		r = range(1e-9,2rmax,length=nr)
		θ = range(0,π,length=nθ)
		x = r .* sin.(θ')
		y = r .* cos.(θ')

		ϕ = 0.0
		B_disc = [discretize(B_p_101, r, θ, ϕ) for r in r, θ in θ] #discretize 3D magnetic field at each r, θ, ϕ
		Br = real.(getindex.(B_disc,1)) #get only the radial component and take real part only of the complex field.
		
		f = Figure(size=(400,500))
		ax = Axis(f[1,2], aspect=DataAspect())
		xlims!(ax,0,rmax)
		ylims!(ax,-rmax,rmax)
		hidespines!(ax)
		hidedecorations!(ax)
		clim = maximum(abs,Br) #get color limits
		s = surface!(ax, x, y, Br, colormap=div_colormap, colorrange=(-clim,clim), shading=NoShading)
		Colorbar(f[1,1],s, vertical=true, label=L"B_r", flipaxis=false, height=400)
		
		lines!(ax, sin.(θ), cos.(θ), color=_theme.textcolor, linestyle=:dash, linewidth=1) #plot r=1 half circle
		
		save(joinpath(@__DIR__,"../figs/magfield_part2_br_$(theme.name).png"), f)

		# figure 2: add streamlines
		function cart2sph(R)
			x,y,z = R
			r = sqrt(x^2+y^2+z^2)
			θ = atan(sqrt(x^2+y^2),z)
			ϕ = atan(y,x)
			return (r,θ,ϕ)
		end
		
		function sph2cartvec(u,R)
			r,θ,ϕ = R
			ur,uθ,uϕ = u
			ux = sin(θ)*cos(ϕ)*ur + cos(θ)*cos(ϕ)*uθ - sin(ϕ)*uϕ
			uy = sin(θ)*sin(ϕ)*ur + cos(θ)*sin(ϕ)*uθ + cos(ϕ)*uϕ 
			uz = cos(θ)*ur - sin(θ)*uθ
			return (ux,uy,uz)
		end
		
		function streamofb0(x,z, B0)
			R = cart2sph((x,0,z))
			b = real.(sph2cartvec(Limace.Discretization.discretize(B0,R...),R))
			return Point2(b[1],b[3])
		end
			
		streamplot!(ax,(x,z)->streamofb0(x,z,B_p_101),-rmax..rmax,-rmax..rmax; color=x->_theme.textcolor[], arrow_size=10,density=0.8, alpha=0.3, stepsize=0.01, maxsteps=1_000_000)
		save(joinpath(@__DIR__,"../figs/magfield_part2_br_with_stream_$(theme.name).png"), f)
	end


end