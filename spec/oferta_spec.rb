require 'rspec'
require_relative "../dominio/usuario"
require_relative "../dominio/oferta"

def crearUsuarioValido
    nombre = 'sabri'
    apellido = 'garcia'
    mail = 'sab@gmail.com'
    fecha_nacimiento = '2004-04-25'
    datos_personales = {"nombre" => nombre, "apellido" => apellido, "mail" => mail, "fecha_nacimiento" => fecha_nacimiento}
    usuario = Usuario.new(datos_personales)
    usuario
end

describe 'Oferta' do
    it 'se inicializa una Oferta con titulo, descripcion y Usuario' do
      usuario = crearUsuarioValido

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
      fecha_publicacion = Date.parse("2024-11-08")
      oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion)

      expect(oferta.titulo).to eq titulo
      expect(oferta.descripcion).to eq descripcion
      expect(oferta.usuario).to eq usuario
    end

    describe 'Validaciones Titulo' do
      it 'deberia lanzar error si no se le provee un titulo a la oferta' do
        usuario = crearUsuarioValido

        titulo = nil
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(ParametroAusente)
      end

      it 'deberia lanzar error si se le pasa un titulo vacio a la oferta' do
        usuario = crearUsuarioValido

        titulo = ""
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(ParametroAusente)
      end

      it 'deberia lanzar error si se le provee un titulo menor a 10 caracteres a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Titulo"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(CantidadDeCaracteresNoValida)
      end

      it 'deberia lanzar error si se le provee un titulo mayor a 30 caracteres a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Este titulo no va a funcionar debido a su longitud"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(CantidadDeCaracteresNoValida)
      end
    end

    describe 'Validaciones Descripcion' do
      it 'deberia lanzar error si no se le provee una descripcion a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Titulo de Oferta"
        descripcion = nil
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(ParametroAusente)
      end

      it 'deberia lanzar error si se le provee una descripcion vacia a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Titulo de Oferta"
        descripcion = ""
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(ParametroAusente)
      end

      it 'deberia lanzar error si se le provee una descripcion mayor a 200 caracteres a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la ofertaxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(CantidadDeCaracteresNoValida)
      end

      it 'deberia lanzar error si se le provee una descripcion menor a 10 caracteres a la oferta' do
        usuario = crearUsuarioValido

        titulo = "Titulo de Oferta"
        descripcion = "dscp"
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")

        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion) }.to raise_error(CantidadDeCaracteresNoValida)
      end
    end

    describe 'Edad máxima y mínima' do
      it 'se inicializa una Oferta con titulo, descripcion, Usuario y edad mínima' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")
        oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion, 25, nil)
  
        expect(oferta.titulo).to eq titulo
        expect(oferta.descripcion).to eq descripcion
        expect(oferta.usuario).to eq usuario
        expect(oferta.edad_minima).to eq 25
        expect(oferta.edad_maxima).to eq nil
      end

      it 'se inicializa una Oferta con titulo, descripcion, Usuario y edad máxima' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        fecha_publicacion = Date.parse("2024-11-08")
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}

        oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion, nil, 50)
  
        expect(oferta.titulo).to eq titulo
        expect(oferta.descripcion).to eq descripcion
        expect(oferta.usuario).to eq usuario
        expect(oferta.edad_minima).to eq nil
        expect(oferta.edad_maxima).to eq 50
      end

      it 'no se puede crear una Oferta con edad mínima menor a 18' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")
  
        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion, 16, nil) }.to raise_error(DatoNoValido)
      end

      it 'no se puede crear una Oferta con edad máxima menor a 18' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")
  
        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion, nil, 17) }.to raise_error(DatoNoValido)
      end

      it 'no se puede crear una Oferta con edad máxima menor a edad mínima' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = Date.parse("2024-11-08")
  
        expect{ Oferta.new(datos_oferta, usuario, fecha_publicacion, 25, 20) }.to raise_error(DatoNoValido)
      end
    end

    describe 'fecha de publicacion' do
      it 'si no se crea con un fecha valida, se le otorga el default' do
        usuario = crearUsuarioValido
  
        titulo = "Titulo de Oferta"
        descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
        datos_oferta = {'titulo' => titulo, 'descripcion' => descripcion}
        fecha_publicacion = nil
        fecha_default = Date.parse("1997-01-24")
  
        oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion)
        
        expect(oferta.fecha_publicacion).to eq fecha_default
      end
    end
end