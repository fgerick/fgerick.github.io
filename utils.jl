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
      # img = pagevar(fi, :postheader)
      push!(posts, (; title, link=fi, date))
  end


  for ele in sort(posts, by=x->x.date, rev=true)
    markdown *= "* [($(ele.date)) $(ele.title)](../$(ele.link))\n"
  end

  return fd2html(markdown, internal=true)
end

@delay function hfun_blogpostsimg()
  list = readdir("posts")
  filter!(f -> endswith(f, ".md") && f != "index.md" , list)
  
  posts = []
  for (k, post) in enumerate(list)
      fi = "posts/" * first(splitext(post))
      title = pagevar(fi, :title)
      date = pagevar(fi, :date)
      img = pagevar(fi, :postheader)
      push!(posts, (; title, link=fi, date, img))
  end

  out = "<ul>"
  for ele in sort(posts, by=x->x.date, rev=true)
    out *= """
    <a href="../$(ele.link)" class="im-20">
    <li class="im-20">
    <img src="$(ele.img)"></img>
    <span class="im-20">
   $(ele.title) <br> ($(ele.date))
   </span>
  </li>
  </a>
  """
  end
  out*="</ul>"

  return out 
  # return fd2html(out, internal=true)
end

function hfun_figurelightdark(fnames)
  generated_html = """<picture>
  <source media="(prefers-color-scheme: dark)" srcset="/assets/$(last(fnames))" />
  <img src="/assets/$(first(fnames))" />
  </picture>"""
  return generated_html
end

function hfun_htmlfigurelightdark(fnames)
  generated_html = """
      <p align="center">
      <iframe id="content-frame" style="width: $(fnames[3])px; height: $(fnames[4])px; border: none"></iframe>
      </p>

    <script>
        function loadContent() {
            const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches;
            const fileToLoad = prefersDark ? "/assets/$(fnames[2])" : "/assets/$(fnames[1])";
            document.getElementById("content-frame").src = fileToLoad;
        }

        // Initial load
        loadContent();

        // Listen for dark mode changes
        window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", loadContent);
    </script>
  """
  return generated_html
end

using DocumenterCitations
using DocumenterCitations: CitationBibliography, CitationLink, format_citation, format_bibliography_reference

const style = :authoryear
bib = CitationBibliography("refs.bib"; style)
page_citations = Dict()

function lx_citeP(com, _)
  # leave this first line, it extracts the content of the brace
  key = Franklin.content(com.braces[1])
  cit = CitationLink("[$(key)](@citep)")
  citations = Dict(k=>1 for k in cit.keys)
  for k in cit.keys
    page_citations[k] = 1
  end
  citat =  format_citation(style, cit, bib.entries, citations)
  citat = replace(citat,r"]\((.*?)\)"=>"](#references)") #hack around
  return citat
end

function lx_citeT(com, _)
  # leave this first line, it extracts the content of the brace
  key = Franklin.content(com.braces[1])
  cit = CitationLink("[$(key)](@citet)")
  citations = Dict(k=>1 for k in cit.keys)
  for k in cit.keys
    page_citations[k] = 1
  end
  citat =  format_citation(style, cit, bib.entries, citations)
  citat = replace(citat,r"]\((.*?)\)"=>"](#references)") #hack around
  return citat
end

function lx_bibliography(com,_)
  out = ""
  for key in keys(page_citations)
    out *= "* "*format_bibliography_reference(style, bib.entries[key])*"\n"
  end
  return out
end