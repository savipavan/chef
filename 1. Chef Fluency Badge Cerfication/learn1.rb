package 'httpd' do
end

service 'httpd' do
  action [:enable,:start]
end

file '/var/www/index.html' do
  action :remove
end

file 'var/www/html/index.html' do
  content 'Hello World! Pavan has written'
  mode '0755'
  owner 'root'
  group 'apache'
end
