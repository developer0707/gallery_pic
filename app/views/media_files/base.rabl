attributes :id, :name
node(:url) do |file|
	file.build_url(request)
end