# frozen_string_literal: true

require_relative '../web_app'
require 'rspec'
require 'rack/test'

describe 'Aplicación Sinatra' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    post '/reset'
  end

  def registrar_usuario_valido
    datos_usuario = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com',fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'corporativa' }
    post '/usuarios', datos_usuario.to_json
  end

  describe 'Registrar Usuario' do
    it 'registrar usuario' do
      datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita'}
      post '/usuarios', datos.to_json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_usuario" => 'juan@test.com' })
    end

    describe 'Validaciones nombre' do
      it 'deberia lanzar error si quiero registrar un usuario sin nombre' do
        datos = { apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesitan nombre y apellido para registrar el usuario' })
      end

      it 'deberia lanzar error si me paso de 30 caracteres en el campo nombre al registrar usuario' do
        datos = { nombre_usuario: 'juannnnnnnnnnnnnnnnnnnnnnnnnnnn', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'tanto el nombre como el apellido deben tener entre 2 y 30 caracteres' })
      end
    end

    describe 'Validaciones apellido' do
      it 'deberia lanzar error si quiero registrar un usuario sin apellido' do
        datos = { nombre_usuario: 'juan', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesitan nombre y apellido para registrar el usuario' })
      end

      it 'deberia lanzar error si me paso de 30 caracteres en el campo apellido al registrar usuario' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perezzzzzzzzzzzzzzzzzzzzzzzzzzz', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'tanto el nombre como el apellido deben tener entre 2 y 30 caracteres' })
      end

      it 'deberia lanzar error si se pasan menos de 2 caracteres en el campo apellido al registrar usuario' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'p', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'tanto el nombre como el apellido deben tener entre 2 y 30 caracteres' })
      end
    end

    describe 'Validaciones mail' do
      it 'registrar un usuario con mail en mayusculas deberia ser lo mismo que en minusculas' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'JUAN@TEST.COM', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq({ "id_usuario" => 'juan@test.com' })
      end
      
      it 'deberia lanzar error si quiero registrar un usuario sin mail' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita'}
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita un mail para registrar el usuario' })
      end

      it 'deberia lanzar error si me paso de 100 caracteres en el campo mail al registrar usuario' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juanpabloestexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'el mail debe tener entre 7 y 100 caracteres' })
      end

      it 'deberia lanzar error si me pasan menos de 7 caracteres en el campo mail al registrar usuario' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'x@xx.a', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'el mail debe tener entre 7 y 100 caracteres' })
      end

      it 'deberia lanzar error si me pasa un mail invalido que no cumple con el formato de mail al registrar usuario' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'jorgepasos.com.ar', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'formato de mail invalido' })
      end

      it 'no se puede registrar un usuario con un mail ya perteneciente a otro usuario' do 
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'jorge@pasos.com.ar', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        
        datos = { nombre_usuario: 'carlos', apellido_usuario: 'paz', mail_usuario: 'jorge@pasos.com.ar', fecha_nacimiento_usuario: '1999-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'Este mail ya esta registrado' })
      end

      it 'no se puede registrar un usuario con un mail ya perteneciente a otro usuario en mayusculas' do 
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'jorge@pasos.com.ar', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        
        datos = { nombre_usuario: 'carlos', apellido_usuario: 'paz', mail_usuario: 'JORGE@PASOS.COM.AR', fecha_nacimiento_usuario: '1999-03-04', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'Este mail ya esta registrado' })
      end
    end

    describe 'Validaciones fecha de nacimiento' do
      it 'deberia lanzar error si quiero registrar un usuario sin fecha de nacimiento' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita una fecha de nacimiento para registrar el usuario' })
      end

      it 'deberia lanzar error si el formato de la fecha no es AAAA-MM-DD' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '04-03-2000', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'fecha de nacimiento no valida, formato debe ser AAAA-MM-DD' })
      end

      it 'deberia lanzar error si la fecha no corresponde a una fecha valida' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-02-31', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'fecha de nacimiento no corresponde a una fecha valida' })
      end

      it 'deberia lanzar error si la fecha corresponde a una edad menor a 18' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2007-02-15', suscripcion: 'gratuita' }
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'No se puede registrar un usuario menor de edad' })
      end

      it 'no deberia lanzar error si la fecha corresponde a una edad mayor a 18' do
        ENV['fecha'] = '2025-10-31'
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2007-02-15', suscripcion: 'gratuita'}
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq({ "id_usuario" => 'juan@test.com' })
      end
    end

    describe 'validaciones suscripcion' do
      it 'deberia lanzar error si quiero registrar un usuario sin tipo de suscripcion' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04'}
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita un tipo de suscripcion para registrar el usuario' })
      end

      it 'deberia lanzar error si quiero registrar un usuario con un tipo de suscripcion no valido' do
        datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratis'}
        post '/usuarios', datos.to_json
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'tipo de suscripcion no valida' })
      end
    end
  end

  describe 'Publicar Oferta' do
    it 'publica una oferta y devuelve su id' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 1 })
    end

    it 'publica una oferta con edad maxima y minima y devuelve su id' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '25', edad_maxima: '50', mail_usuario: 'juan@test.com'}
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 1 })
    end

    it 'publica una oferta con edad maxima y devuelve su id' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_maxima: '50', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 1 })
    end

    it 'publica una oferta con edad minima y devuelve su id' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '25', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 1 })
    end

    it 'publica una oferta y devuelve su id por mas que el mail sea el mismo en mayusculas' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'JUAN@TEST.COM' }
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 1 })
    end
    
    describe 'Validaciones publicar oferta' do
      it 'deberia lanzar error si quiero publicar una oferta sin titulo' do
        registrar_usuario_valido

        datos_oferta = { descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita un titulo para publicar una oferta'})
      end

      it 'deberia lanzar error si quiero publicar una oferta sin una descripcion' do
        registrar_usuario_valido

        datos_oferta = {titulo: 'Titulo de Oferta', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita una descripcion para publicar una oferta'})
      end

      it 'deberia lanzar error si quiero publicar una oferta sin un mail' do
        registrar_usuario_valido

        datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'se necesita un mail para publicar una oferta'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con un titulo menor a 10 caracteres' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'el titulo debe tener entre 10 y 30 caracteres'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con un titulo mayor a 30 caracteres' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Este es un titulo que es invalido', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'el titulo debe tener entre 10 y 30 caracteres'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con una descripcion mayor a 200 caracteres' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la ofertaxxxxxxxxxxxxxxx
        xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'la descripcion debe tener entre 10 y 200 caracteres'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con una descripcion menor a 10 caracteres' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de oferta', descripcion: 'dspc', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'la descripcion debe tener entre 10 y 200 caracteres'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con un mail que no corresponde a un usuario registrado' do
        datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'mail no corresponde a un usuario registrado'})
      end
    end
  end

  describe 'Consultar Ofertas' do
    it 'devuelve el titulo y descripción de una oferta en particular, con el nombre, apellido y mail del usuario que la publicó' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      id_consultada = 1
      get "/ofertas/#{id_consultada}"

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({
      "titulo" => 'Titulo de Oferta',
      "descripcion" => 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',
      "nombre_usuario" => 'juan',
      "apellido_usuario" => 'perez',
      "mail_usuario" => 'juan@test.com'
      })
    end

    it 'deberia lanzar error si no se encuentra una oferta' do
      datos_usuario = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita' }
      post '/usuarios', datos_usuario.to_json

      titulo1 = 'Titulo de Oferta'
      descripcion1 = 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.'
      
      datos_oferta1 = { titulo: titulo1, descripcion: descripcion1, mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta1.to_json

      id_consultada = 2
      get "/ofertas/#{id_consultada}"

      expect(last_response.status).to eq 404
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'oferta no encontrada' })
    end
    
    it 'lista todas las ofertas publicadas con su id, titulo y descripcion' do
      registrar_usuario_valido

      titulo1 = 'Titulo de Oferta'
      descripcion1 = 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.'
      
      datos_oferta1 = { titulo: titulo1, descripcion: descripcion1, mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta1.to_json
      
      titulo2 = 'Titulo de Otra Oferta'
      descripcion2 = 'Esto es la descripcion de la otra oferta. Tiene datos sobre la otra oferta.'
      
      datos_oferta2 = { titulo: titulo2, descripcion: descripcion2, mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta2.to_json

      resultado_oferta1 = {"ID"=>1, "titulo_oferta"=>titulo1, "descripcion_oferta"=> descripcion1}
      resultado_oferta2 = {"ID"=>2, "titulo_oferta"=>titulo2, "descripcion_oferta"=> descripcion2}

      get '/ofertas'
      expect(last_response).to be_ok
      expect(JSON.parse(last_response.body)[0]).to eq resultado_oferta1
      expect(JSON.parse(last_response.body)[1]).to eq resultado_oferta2
    end

    describe 'para ofertas con parametros opcionales edad minima y/o maxima' do
      it 'devuelve el titulo, descripción, edad minima y edad maxima de una oferta en particular, con el nombre, apellido y mail del usuario que la publicó' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',  edad_minima: '25', edad_maxima: '50', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        id_consultada = 1
        get "/ofertas/#{id_consultada}"

        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq({
        "titulo" => 'Titulo de Oferta',
        "descripcion" => 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',
        "nombre_usuario" => 'juan',
        "apellido_usuario" => 'perez',
        "edad_minima" => '25',
        "edad_maxima" => '50',
        "mail_usuario" => 'juan@test.com'
        })
      end

      it 'devuelve el titulo, descripción y edad minima de una oferta en particular, con el nombre, apellido y mail del usuario que la publicó' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',  edad_minima: '25', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        id_consultada = 1
        get "/ofertas/#{id_consultada}"

        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq({
        "titulo" => 'Titulo de Oferta',
        "descripcion" => 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',
        "nombre_usuario" => 'juan',
        "apellido_usuario" => 'perez',
        "edad_minima" => '25',
        "mail_usuario" => 'juan@test.com'
        })
      end

      it 'devuelve el titulo, descripción y edad maxima de una oferta en particular, con el nombre, apellido y mail del usuario que la publicó' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_maxima: '50', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        id_consultada = 1
        get "/ofertas/#{id_consultada}"

        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to eq({
        "titulo" => 'Titulo de Oferta',
        "descripcion" => 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',
        "nombre_usuario" => 'juan',
        "apellido_usuario" => 'perez',
        "edad_maxima" => '50',
        "mail_usuario" => 'juan@test.com'
        })
      end

      it 'deberia lanzar error si quiero publicar una oferta con edad minima menor a 18 años' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '15', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'La edad del postulante no puede ser menor a 18 años'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con edad maxima menor a 18 años' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_maxima: '15', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'La edad del postulante no puede ser menor a 18 años'})
      end

      it 'deberia lanzar error si quiero publicar una oferta con edad minima mayor a edad máxima' do
        registrar_usuario_valido

        datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '30', edad_maxima: '25', mail_usuario: 'juan@test.com' }
        post '/ofertas', datos_oferta.to_json

        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'La edad máxima no puede ser menor a la edad mínima'})
      end
    end
  end

  describe 'Actualizar oferta' do
    it 'deberia actualizarse una oferta con todos los parametros nuevos sin edad minima ni maxima' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', mail_usuario: 'juan@test.com' }

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta_actualizada" => 1 })

      get "/ofertas/#{id_a_actualizar}"

      expect(JSON.parse(last_response.body)).to eq({
      "titulo" => 'Titulo de Oferta',
      "descripcion" => 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.',
      "nombre_usuario" => 'juan',
      "apellido_usuario" => 'perez',
      "mail_usuario" => 'juan@test.com'
      })

    end

    it 'deberia actualizarse una oferta con todos los parametros nuevos incluidos edad minima y maxima' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '19', edad_maxima: '40', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', edad_minima: '25', edad_maxima: '50', mail_usuario: 'juan@test.com' }

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta_actualizada" => 1 })

      get "/ofertas/#{id_a_actualizar}"

      expect(JSON.parse(last_response.body)).to eq({
      "titulo" => 'Titulo de Oferta',
      "descripcion" => 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.',
      "nombre_usuario" => 'juan',
      "apellido_usuario" => 'perez',
      "edad_minima" => '25',
      "edad_maxima" => '50',
      "mail_usuario" => 'juan@test.com'
      })
    end

    it 'deberian agregarse los datos de edad por mas que la oferta original no los tuviera' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.',  mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', edad_minima: '20', edad_maxima: '50', mail_usuario: 'juan@test.com' }

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta_actualizada" => 1 })

      get "/ofertas/#{id_a_actualizar}"

      expect(JSON.parse(last_response.body)).to eq({
      "titulo" => 'Titulo de Oferta',
      "descripcion" => 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.',
      "nombre_usuario" => 'juan',
      "apellido_usuario" => 'perez',
      "edad_minima" => '20',
      "edad_maxima" => '50',
      "mail_usuario" => 'juan@test.com'
      })
    end

    it 'deberian eliminarse los datos de edad si en la actualizacion esos campos estan vacios'  do
      registrar_usuario_valido
  
      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', edad_minima: '19', edad_maxima: '40', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json
  
      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', mail_usuario: 'juan@test.com' }
  
      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json
      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta_actualizada" => 1 })
  
      get "/ofertas/#{id_a_actualizar}"
  
      expect(JSON.parse(last_response.body)).to eq({
      "titulo" => 'Titulo de Oferta',
      "descripcion" => 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.',
      "nombre_usuario" => 'juan',
      "apellido_usuario" => 'perez',
      "mail_usuario" => 'juan@test.com'
      })
    end
  
    it 'no deberia poder actualizar los datos de una oferta si el dueño no es el original' do
      registrar_usuario_valido
      datos_usuario2 = { nombre_usuario: 'rodrigo', apellido_usuario: 'florentino', mail_usuario: 'rodrigo@test.com',fecha_nacimiento_usuario: '2005-02-04', suscripcion: 'gratuita' }
      post '/usuarios', datos_usuario2.to_json

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', mail_usuario: 'rodrigo@test.com' }

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'Solamente el dueño de la oferta puede actualizarla'})
    end

    it 'no deberia poder actualizar los datos de una oferta si me pasan una descripcion invalida' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'invalida', mail_usuario: 'juan@test.com' }

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'la descripcion debe tener entre 10 y 200 caracteres'})
    end

    it 'no deberia poder actualizar los datos de una oferta que no existe' do
      registrar_usuario_valido

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', mail_usuario: 'juan@test.com' }

      id_de_oferta_no_existente = 1
      put "/ofertas/#{id_de_oferta_no_existente}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'oferta no encontrada'})
    end

    it 'no deberia poder actualizar los datos de una oferta si se pasan edades invalidas' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', edad_minima: '14', edad_maxima: '50', mail_usuario: 'juan@test.com'}

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'La edad del postulante no puede ser menor a 18 años'})
    end

    it 'no deberia poder actualizar los datos de una oferta si no me pasan una descripcion' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', edad_minima: '19', edad_maxima: '50', mail_usuario: 'juan@test.com'}

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'Se necesita una descripcion y un mail para actualizar una oferta'})
    end

    it 'no deberia poder actualizar los datos de una oferta si no me pasan un mail' do
      registrar_usuario_valido

      datos_oferta = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json

      datos_oferta_actualizados = { titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada.', edad_minima: '19', edad_maxima: '50'}

      id_a_actualizar = 1
      put "/ofertas/#{id_a_actualizar}", datos_oferta_actualizados.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'Se necesita una descripcion y un mail para actualizar una oferta'})
    end
  end

  describe 'Publicar ofertas según tipo de suscripción' do
    it 'deberia lanzar error si quiero publicar más de una oferta al mes con suscripción gratuita' do
      datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita'}
      post '/usuarios', datos.to_json

      datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'la suscripcion no permite hacer mas publicaciones'})
    end

    it 'deberia permitir publicar más de una oferta con suscripción gratuita si son diferentes meses' do
      datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'gratuita'}
      post '/usuarios', datos.to_json

      datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      ENV['fecha'] = '2024-10-31'
      post '/ofertas', datos_oferta.to_json
      ENV['fecha'] = '2025-11-01'
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 2 })
    end

    it 'deberia lanzar error si quiero publicar más de cinco ofertas al mes con suscripción profesional' do
      datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'profesional'}
      post '/usuarios', datos.to_json

      datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)).to eq({ "mensaje" => 'la suscripcion no permite hacer mas publicaciones'})
    end

    it 'deberia poder publicar ofertas ilimitadas por mes si el usuario tiene una suscripcion corporativa' do
      datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'corporativa'}
      post '/usuarios', datos.to_json

      datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json
      post '/ofertas', datos_oferta.to_json

      expect(last_response.status).to eq 200
      expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 8 })
    end
  end

  it 'deberia permitir publicar más de cinco ofertas con suscripción profesional si son diferentes meses' do
    datos = { nombre_usuario: 'juan', apellido_usuario: 'perez', mail_usuario: 'juan@test.com', fecha_nacimiento_usuario: '2000-03-04', suscripcion: 'profesional'}
    post '/usuarios', datos.to_json

    datos_oferta = {titulo: 'Titulo de Oferta', descripcion: 'Esto es la descripcion de la oferta. Tiene datos sobre la oferta.', mail_usuario: 'juan@test.com' }
    ENV['fecha'] = '2024-10-31'
  
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json

    ENV['fecha'] = '2024-11-01'
    
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json
    post '/ofertas', datos_oferta.to_json

    expect(last_response.status).to eq 200
    expect(JSON.parse(last_response.body)).to eq({ "id_oferta" => 10 })
  end
end
