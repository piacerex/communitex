defmodule SphereShared do

  def mail_folder(), do: Path.join( SphereShared.content_physical_path(), "mail" )

  def content_physical_path(), do: Path.join( Application.fetch_env!( :sphere, :local_root ), Application.fetch_env!( :sphere, :content_folder ) )

end
