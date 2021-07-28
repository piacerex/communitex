defmodule GitOperator do
  def clone( pwd ) do
    clone_path = Path.join( Application.fetch_env!( :sphere, :local_root ), Application.fetch_env!( :sphere, :content_folder ) )
    github_url = Application.fetch_env!( :sphere, :github_url )
    result = try do
      File.cd!( Path.dirname( clone_path ) )

      IO.puts "================================="
      IO.puts "================================="
      IO.puts "START clone"
      IO.puts "================================="
      IO.puts "================================="

      Git.clone!( github_url )
      File.cd!( pwd )
      repo = Git.new( clone_path )
      Git.config!( repo, [ "user.email", "admin@communitex.org" ] )
      Git.config!( repo, [ "user.password", "" ] )

      result = "clone complete: " <> inspect File.ls!( clone_path )

      IO.puts "================================="
      IO.puts "================================="
      IO.puts result
      IO.puts "================================="
      IO.puts "================================="
      result
    rescue
      error -> 
        File.cd!( pwd )
        result = inspect error
        IO.puts "-----------------------------------------"
        IO.puts result
        IO.puts "-----------------------------------------"
        result
    end
    result
  end

  def push( content_path, operation ) do
		try do
			repo = Git.new( content_path )
			Git.status!( repo )
			Git.add( repo, "." )
			Git.commit!( repo, [ "-m", "Sphere #{ operation } with Elixir Git CLI" ] )
			Git.push!( repo, [ "-f" ] )
		rescue
			error -> 
				IO.puts "-----------------------------------------"
				IO.puts "[[[ Github #{ operation } commit/push failure ]]]"
				IO.inspect error
				IO.puts "-----------------------------------------"
		end
  end

end
