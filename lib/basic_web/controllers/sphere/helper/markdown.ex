defmodule Markdown do

	def dispatch( relative_path, body, params, conn, current_email ) do
		case body do
			""       -> Markdown.new(    current_email )
			"folder" -> Markdown.folder( current_email )
			_        -> 
				case Path.extname( relative_path ) do
					".eex"  -> case relative_path |> String.split_at( -4 ) |> elem( 0 ) |> Path.extname do
					    ".html" -> eex( body, params, conn, current_email )
					    ".json" -> eex( body, params, conn, current_email )
					  end
					".png"  -> image( relative_path, current_email )
					".jpg"  -> image( relative_path, current_email )
					".gif"  -> image( relative_path, current_email )
					".ico"  -> unsupported(          current_email )
					".md"   -> markdown( body,       current_email )
					".html" -> plane(    body,       current_email )
					_       -> plane(    body,       current_email ) |> Map.merge( %{ "naked" => true } )
				end
		end
		|> Map.merge(
			%{
				"path" => relative_path, 
			} )
	end

	def eex( body, params, conn, current_email ) do
	  compiled_body = case params do
	    :no_eval -> body
	    params   -> body |> String.replace( "@params", "params" ) |> EEx.eval_string( [ params: params, conn: conn ] )
	  end
	  parse( compiled_body, current_email, true,  true )
	end
	def plane(    body, current_email ), do: parse( body, current_email, true,  true )
	def markdown( body, current_email ), do: parse( body, current_email, false, true )
	def parse(    body, current_email, raw, savable ) do
		pattern = 
			"<!--\n" <>
			"Title: "       <> "(?<title>.*)"       <> "\n" <>
			"CreateDate: "  <> "(?<create_date>.*)" <> "\n" <>
			"Creator: "     <> "(?<creator>.*)"     <> "\n" <>
			"UpdateDate: "  <> ".*"                 <> "\n" <>
			"Updater: "     <> ".*"                 <> "\n" <>
			"-->\n" <>
			"\n" <>
			"(?<body>(.|\n)*)"
		regex = Regex.compile!( pattern )
    case Regex.named_captures( regex, body ) do
      nil    -> init( body, current_email, raw, savable )
      result -> result
    end
		|> Map.merge(
			%{
				"raw"     => raw, 
				"savable" => savable, 
				"updater" => current_email, 
			} )
	end

	def new(         current_email ), do: init( "",                           current_email, true, true  )
	def image( path, current_email ), do: init( "<img src=\"#{ path }\">",    current_email, true, false )
	def folder(      current_email ), do: init( "（フォルダです）",           current_email, true, false )
	def unsupported( current_email ), do: init( "（サポートされていません）", current_email, true, false )
	def init( body, current_email, raw, savable ) do
		%{
			"title"			=> "", 
			"create_date"	=> Dt.to_ymdhmsl( Timex.now ), 
			"creator"		=> current_email, 
			"update_date"	=> "", 
			"updater"		=> current_email, 
			"body"			=> body, 
			"raw"			=> raw, 
			"savable"		=> savable, 
		}
	end
end
