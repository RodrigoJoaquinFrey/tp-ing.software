# frozen_string_literal: true

require 'rspec'
require_relative '../dominio/oferta'
require_relative '../adaptadores/repositorio_ofertas_redis'


describe 'RepositorioOfertasRedisSpec' do

  it 'guardar ' do
    repo = RepositorioOfertasRedis.new
    repo.reset
    oferta = Oferta.new('programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com')
    resultado = repo.guardar(oferta)
    expect(resultado).to eq 1
  end

  describe 'listar' do
    it 'listar sin tener ofertas devuelve vacio' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      resultado = repo.listar
      expect(resultado).to eq []
    end

    it 'listar con una oferta devuelva la misma con su id' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com')
      repo.guardar(oferta)
      resultado = repo.listar
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'Programador ruby'
      expect(oferta.descripcion).to eq 'lkasjdo12ijlkasd'
      expect(oferta.mail).to eq 'nico@gmail.com'
    end

    it 'listar con una oferta devuelva la misma con su id y remuneracion' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'remuneracion_ofrecida' => 3000})
      repo.guardar(oferta)
      resultado = repo.listar
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'Programador ruby'
      expect(oferta.descripcion).to eq 'lkasjdo12ijlkasd'
      expect(oferta.mail).to eq 'nico@gmail.com'
      expect(oferta.remuneracion_ofrecida).to eq 3000
    end

    it 'listar con una oferta devuelva la misma con su id y edad minima de postulacion' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'edad_minima_postulacion' => 18})
      repo.guardar(oferta)
      resultado = repo.listar
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'Programador ruby'
      expect(oferta.descripcion).to eq 'lkasjdo12ijlkasd'
      expect(oferta.mail).to eq 'nico@gmail.com'
      expect(oferta.edad_minima_postulacion).to eq 18
    end

    it 'listar con una oferta devuelva la misma con su id y etiquetas' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta)
      resultado = repo.listar
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'Programador ruby'
      expect(oferta.descripcion).to eq 'lkasjdo12ijlkasd'
      expect(oferta.mail).to eq 'nico@gmail.com'
      expect(oferta.etiquetas[0]).to eq 'ruby'
    end
  end
  
  describe 'recuperar' do
    it 'recuperar una oferta con id inexistente arroja error' do
      expect do
        repo = RepositorioOfertasRedis.new
      repo.reset
      repo.recuperar("o:224")
      end.to(raise_error(IdOfertaInexistenteError))
    end
  end

  describe 'buscar por etiqueta' do
    it 'con una sola etiqueta debería devolver una lista de todas las ofertas que la contienen' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta)
      oferta2 = Oferta.new('Programador java', 'lkasjdo12ijlkasd', 'nico@gmail.com')
      repo.guardar(oferta2)
      ofertas = repo.buscar_por_etiqueta(['tdd'])
      expect(ofertas.size).to eq 1
    end

    it 'con una sola etiqueta debería devolver una lista de todas las ofertas que la contienen' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta)
      oferta2 = Oferta.new('Programador java', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta2)
      ofertas = repo.buscar_por_etiqueta(['tdd'])
      expect(ofertas.size).to eq 2
    end

    it 'con varias etiquetas debería devolver una lista de todas las ofertas que la contienen' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta)
      oferta2 = Oferta.new('Programador java', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['java', 'tdd']})
      repo.guardar(oferta2)
      ofertas = repo.buscar_por_etiqueta(['tdd','java'])
      expect(ofertas.size).to eq 1
    end

    it 'debería devolver una lista vacia si ninguna oferta contiene todas las etiquetas buscadas' do
      repo = RepositorioOfertasRedis.new
      repo.reset
      oferta = Oferta.new('Programador ruby', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['ruby', 'tdd']})
      repo.guardar(oferta)
      oferta2 = Oferta.new('Programador java', 'lkasjdo12ijlkasd', 'nico@gmail.com', {'etiquetas' => ['java', 'tdd']})
      repo.guardar(oferta2)
      ofertas = repo.buscar_por_etiqueta(['ruby','java'])
      expect(ofertas.size).to eq 0
    end
  end
end
