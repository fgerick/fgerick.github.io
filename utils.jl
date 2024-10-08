function hfun_bar(vname)
  val = Meta.parse(vname[1])
  return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
  var = vname[1]
  return pagevar("index", var)
end

function lx_baz(com, _)
  # keep this first line
  brace_content = Franklin.content(com.braces[1]) # input string
  # do whatever you want here
  return uppercase(brace_content)
end

@delay function hfun_recentblogposts()
  list = readdir("posts")
  filter!(f -> endswith(f, ".md") && f != "index.md" , list)
  markdown = ""
  posts = []
  for (k, post) in enumerate(list)
      fi = "posts/" * first(splitext(post))
      title = pagevar(fi, :title)
      date = pagevar(fi, :date)
      push!(posts, (; title, link=fi, date))
  end


  for ele in sort(posts, by=x->x.date, rev=true)
    markdown *= "* [($(ele.date)) $(ele.title)](../$(ele.link))\n"
  end

  return fd2html(markdown, internal=true)
end

function hfun_figurelightdark(fnames)
  generated_html = """<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/assets/$(last(fnames))" />
  <img src="/assets/$(first(fnames))" />
  </picture>"""
  return generated_html
end