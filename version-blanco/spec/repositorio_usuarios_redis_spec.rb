# frozen_string_literal: true

require 'rspec'
require_relative '../dominio/usuario'
require_relative '../adaptadores/repositorio_usuarios_redis'


describe 'RepositorioUsuariosRedisSpec' do

  it 'guardar ' do
    repo = RepositorioUsuariosRedis.new
    repo.reset
    usuario = Usuario.new('nico', 'paez', 'nico@gmail.com', '2002-02-20')
    id =  repo.guardar(usuario)
    expect(id).to eq 'nico@gmail.com'
    expect(repo.size).to eq 1
  end

end
