# frozen_string_literal: true

require_relative '../web_app'
require 'rspec'
require 'rack/test'
require 'json'

NOMBRE_USUARIO = 'Thorfinn'
APELLIDO_USUARIO = 'Thors'
MAIL_USUARIO = 'massiminoagustin@gmail.com' #ESTE MAIL RECIBE CUANDO SE EJECUTA EN ENV TEST
FECHA_NACIMIENTO_USUARIO = '2002-02-20'
TITULO_OFERTA_EXTENSO="Desarrollador Ruby on Rails – Proyecto Web Dinámico"
DESCRIPCION_OFERTA="Desarrollador Ruby on Rails para crear y optimizar aplicaciones web. Se requiere experiencia en desarrollo ágil y pruebas automatizadas."
TITULO_OFERTA="Dev Ruby on Rails – Web App"
REMUNERACION_OFRECIDA=3000
UBICACION_OFERTA='Buenos Aires'
EDAD_MINIMA_POSTULACION=18
ETIQUETAS = 'ruby, TDD'



describe 'Aplicación Sinatra' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def respuesta_campo(respuesta, campo)
    JSON.parse(respuesta.body)[campo]
  end

  before(:each) do
    post '/reset'
    ENV['FECHA_ACTUAL'] = nil
  end

  def crear_usuario(nombre=NOMBRE_USUARIO,apellido=APELLIDO_USUARIO,mail=MAIL_USUARIO, fecha_nacimiento=FECHA_NACIMIENTO_USUARIO)
    datos = { nombre_usuario: nombre, apellido_usuario: apellido, mail_usuario: mail, fecha_nacimiento_usuario: fecha_nacimiento }
    post '/usuarios', datos.to_json
  end
  
  def crear_oferta(titulo=TITULO_OFERTA,descripcion=DESCRIPCION_OFERTA,mail=MAIL_USUARIO, remuneracion_ofrecida=nil,ubicacion_oferta=nil, edad_minima_postulacion=nil, etiquetas=nil)
    datos = { titulo_oferta: titulo, descripcion_oferta: descripcion, mail_usuario: mail, remuneracion_ofrecida:, ubicacion_oferta:, edad_minima_postulacion:, etiquetas:}
    post '/ofertas', datos.to_json
  end

  def postularse(id_oferta, mail_usuario_postulado, nombre_usuario_postulado, apellido_usuario_postulado, fecha_nacimiento_postulado)
    datos = {mail_usuario_postulado: mail_usuario_postulado, nombre_usuario_postulado: nombre_usuario_postulado,
             apellido_usuario_postulado: apellido_usuario_postulado, fecha_nacimiento_postulado: fecha_nacimiento_postulado}
    post "/ofertas/#{id_oferta}/postulaciones", datos.to_json
  end

  def buscar_ofertas_por_titulo(titulo_buscado)
    get '/ofertas/busqueda', { titulo: titulo_buscado }
  end

  def buscar_ofertas_por_etiquetas(etiquetas_buscadas)
    get '/ofertas/busqueda', {etiquetas: etiquetas_buscadas}
  end

  def buscar_ofertas_por_usuario(usuario_buscado)
    get '/ofertas', { mail_usuario: usuario_buscado }
  end

  describe 'registrar usuario' do
    it 'registrar usuario, caso feliz' do
      crear_usuario
      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_usuario')).to eq MAIL_USUARIO
    end

    it 'registrar usuario con email sin arroba' do
      mensaje_esperado = "El mail no es valido. Formato esperado: ejemplo@dominio.com"
      crear_usuario(NOMBRE_USUARIO,APELLIDO_USUARIO,'aaasdwq.com', FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario con nombre menor a 3 caracteres' do
      mensaje_esperado = 'El nombre debe tener un mínimo de 3 caracteres'
      crear_usuario('ab',APELLIDO_USUARIO,MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario con nombre caracteres invalidos' do
      mensaje_esperado = 'Nombre con caracteres invalidos'
      crear_usuario('ab!123',APELLIDO_USUARIO,MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario con apellido menor a 3 caracteres' do
      mensaje_esperado = 'El apellido debe tener un mínimo de 3 caracteres'
      crear_usuario(NOMBRE_USUARIO,'zz',MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario con apellido caracteres invalidos' do
      mensaje_esperado = 'Apellido con caracteres invalidos'
      crear_usuario(NOMBRE_USUARIO,'me$$1',MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario sin enviar nombre' do
      mensaje_esperado = 'Falta parametro obligatorio nombre_usuario'
      crear_usuario(nil, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario sin enviar apellido' do
      mensaje_esperado = 'Falta parametro obligatorio apellido_usuario'
      crear_usuario(NOMBRE_USUARIO, nil, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario sin enviar email' do
      mensaje_esperado = 'Falta parametro obligatorio mail_usuario'
      crear_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, nil, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario sin enviar fecha de nacimiento' do
      mensaje_esperado = 'Falta parametro obligatorio fecha_nacimiento_usuario'
      crear_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, nil)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'registrar usuario con fecha de nacimiento invalida' do
      mensaje_esperado = 'Fecha invalida. Formato YYYY-MM-DD'
      crear_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, '4 de noviembre')
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end
  end

  describe 'crear oferta' do
    it 'crear oferta, caso feliz' do
      crear_usuario
      crear_oferta
      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_oferta')).to eq 1
    end

    it 'crear oferta con titulo mayor a 30 caracteres devuelve mensaje de error' do
      mensaje_esperado = 'El titulo debe tener un maximo de 30 caracteres'
      crear_usuario
      crear_oferta(TITULO_OFERTA_EXTENSO,DESCRIPCION_OFERTA,MAIL_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'crear oferta con un usuario no registrado (mail no encontrado) devuelve mensaje de error' do
      mensaje_esperado = 'Usuario no registrado'
      crear_oferta
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'crear oferta sin enviar titulo arroja error' do
      mensaje_esperado = 'Falta parametro obligatorio titulo_oferta'
      crear_oferta(nil,DESCRIPCION_OFERTA,MAIL_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'crear oferta sin enviar titulo arroja error' do
      mensaje_esperado = 'Falta parametro obligatorio descripcion_oferta'
      crear_oferta(TITULO_OFERTA,nil,MAIL_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'crear oferta sin enviar mail arroja error' do
      mensaje_esperado = 'Falta parametro obligatorio mail_oferente'
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,nil)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'crear oferta con remuneracion'do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA)
      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_oferta')).to eq 1
    end

    it 'se crea una oferta agregando la ubicacion'do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA)
      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_oferta')).to eq 1
    end

    it 'se crea una oferta con una edad minima de postulacion'do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION)
      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_oferta')).to eq 1
    end

    it 'se crea una oferta con etiquetas'do
      crear_usuario      
      
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)

      expect(last_response.status).to eq 200
      expect(respuesta_campo(last_response, 'id_oferta')).to eq 1
    end

    it 'no se debería poder crear una oferta con más de 5 etiquetas'do
      mensaje_esperado = 'No se aceptan mas de 5 etiquetas'
      crear_usuario      
      muchas_etiquetas = "ruby, tdd, job, rails, linux, docker"
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, muchas_etiquetas)

      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'no se debería poder crear una oferta con etiquetas de menos de 3 caracteres'do
      mensaje_esperado = 'Cada etiqueta debe tener entre 3 y 20 caracteres'
      crear_usuario      
      etiquetas_una_corta = "ruby, tdd, js, linux"
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, etiquetas_una_corta)

      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'no se debería poder crear una oferta con etiquetas de más de 20 caracteres'do
      mensaje_esperado = 'Cada etiqueta debe tener entre 3 y 20 caracteres'
      crear_usuario      
      etiquetas_una_larga = "ruby, tdd, linux, ruby on rails developer"
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, etiquetas_una_larga)

      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'no se debería poder crear una oferta con etiquetas repetidas'do
      mensaje_esperado = 'No se aceptan etiquetas repetidas'
      crear_usuario      
      etiquetas_una_larga = "ruby, tdd, ruby"
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, etiquetas_una_larga)

      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'se crea una oferta con una edad minima de postulacion distinta a un numero entre 0 y 99 y devuelve 400'do
      mensaje_esperado = "El campo de edad mínima debe ser un entero entre 0 y 99"
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,-2)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'se crea una oferta con una edad minima de postulacion distinta a un numero entre 0 y 99 y devuelve 400'do
      mensaje_esperado = "El campo de edad mínima debe ser un entero entre 0 y 99"
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,'aaa')
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end
  end

  describe 'listar ofertas' do
    it 'listar ofertas sin haber creado ninguna devuelve vacio' do
      get "/ofertas"
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas')).to eq []
    end

    it 'listar ofertas con una oferta la devuelve dentro de una lista' do
      crear_usuario
      crear_oferta
      get "/ofertas"
      expect(last_response).to be_ok
      resultado = respuesta_campo(last_response, 'ofertas')
      expect(resultado[0]['titulo']).to eq TITULO_OFERTA
      expect(resultado[0]['descripcion']).to eq DESCRIPCION_OFERTA
      expect(resultado[0]['mail_oferente']).to eq MAIL_USUARIO
    end

    it 'listar ofertas con una oferta sin remuneracion devuelve no especificada en el campo de remuneracion_ofrecida' do
      crear_usuario
      crear_oferta
      get "/ofertas"
      expect(last_response).to be_ok
      resultado = respuesta_campo(last_response, 'ofertas')
      expect(resultado[0]['remuneracion_ofrecida']).to eq nil
    end

    it 'listar ofertas con una oferta creada con remuneracion 3000, se lista con 3000 en el campo remuneracion_ofrecida' do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA)
      get "/ofertas"
      expect(last_response).to be_ok
      resultado = respuesta_campo(last_response, 'ofertas')
      expect(resultado[0]['remuneracion_ofrecida']).to eq REMUNERACION_OFRECIDA
    end

    it 'listar ofertas con una oferta creada con ubicacion, se lista con Buenos Aires en el campo ubicacion_oferta' do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA)
       
      get "/ofertas"
      expect(last_response).to be_ok
      resultado = respuesta_campo(last_response, 'ofertas')
      expect(resultado[0]['ubicacion_oferta']).to eq UBICACION_OFERTA
    end
  end

  describe 'postularse a una oferta' do
    it 'postularse a una oferta devuelve 201 y envia un mail' do
      crear_usuario
      crear_oferta
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 201
    end

    it 'postularse a una oferta con el mismo correo dos veces arroja error' do
      mensaje_esperado = 'El mail ya se encuentra postulado a la oferta'
      crear_usuario
      crear_oferta
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'postularse a una oferta inexistente arroja error' do
      mensaje_esperado = 'El id ingresado no se encuentra asociado a ninguna oferta'
      postularse(20, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'se puede postular a una oferta con la edad mínima requerida' do
      ENV['FECHA_ACTUAL'] = '2024-11-10'
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(last_response.status).to eq 201
    end

    it 'no se puede postular a una oferta sin cumplir con la edad mínima requerida' do
      mensaje_esperado = "La edad mínima para postularse es #{EDAD_MINIMA_POSTULACION}"
      ENV['FECHA_ACTUAL'] = '2024-11-10'
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, '2010-11-10')
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'se puede postular a una oferta teniendo exactamente la edad minima requerida' do
      ENV['FECHA_ACTUAL'] = '2028-11-10'
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, '2010-11-10')
      expect(last_response.status).to eq 201
    end

    it 'No se puede postular a una oferta aunque falten dias o meses para tener la edad minima' do
      mensaje_esperado = "La edad mínima para postularse es #{EDAD_MINIMA_POSTULACION}"
      ENV['FECHA_ACTUAL'] = '2028-11-10'
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
      postularse(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO,APELLIDO_USUARIO, '2010-12-10')
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'postular un usuario a una oferta devuelve las ofertas sugeridas' do
      crear_usuario
      crear_oferta(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
    
      crear_usuario('Juan', 'Ramirez', 'juan@gmail.com', FECHA_NACIMIENTO_USUARIO)
      crear_oferta('Esclavitud en Java', 'descripcion', MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
    
      postularse(id_oferta, 'juan@gmail.com', 'Juan', 'Ramirez', FECHA_NACIMIENTO_USUARIO)
    
      expect(last_response.status).to eq 201
    
      ofertas_sugeridas = respuesta_campo(last_response, 'ofertas_sugeridas')
    
      expect(ofertas_sugeridas).to eq([
        {
          "id" => 2,
          "titulo" => "Esclavitud en Java",
          "descripcion" => "descripcion",
          "mail" => "massiminoagustin@gmail.com",
          "remuneracion" => 3000,
          "ubicacion_oferta" => "Buenos Aires",
          "etiquetas" => ["ruby", "tdd"],
          "edad_minima_postulacion" => 18
        }
      ])
    end

    it 'postular un usuario a una oferta devuelve las ofertas sugeridas en orden de coincidencia de etiquetas' do
      crear_usuario
      crear_oferta(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
    
      crear_usuario('Juan', 'Ramirez', 'juan@gmail.com', FECHA_NACIMIENTO_USUARIO)
      crear_oferta('Esclavitud en Java', 'descripcion', MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('Esclavitud en Python', 'descripcion', MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, 'ruby')
      
      postularse(id_oferta, 'juan@gmail.com', 'Juan', 'Ramirez', FECHA_NACIMIENTO_USUARIO)
    
      expect(last_response.status).to eq 201
    
      ofertas_sugeridas = respuesta_campo(last_response, 'ofertas_sugeridas')
    
      expect(ofertas_sugeridas).to eq([
        {
          "id" => 2,
          "titulo" => "Esclavitud en Java",
          "descripcion" => "descripcion",
          "mail" => "massiminoagustin@gmail.com",
          "remuneracion" => 3000,
          "ubicacion_oferta" => "Buenos Aires",
          "etiquetas" => ["ruby", "tdd"],
          "edad_minima_postulacion" => 18
        },
        {
          "id" => 3,
          "titulo" => "Esclavitud en Python",
          "descripcion" => "descripcion",
          "mail" => "massiminoagustin@gmail.com",
          "remuneracion" => 3000,
          "ubicacion_oferta" => "Buenos Aires",
          "etiquetas" => ["ruby"],
          "edad_minima_postulacion" => 18
        }
      ])
    end

    it 'postular un usuario a una oferta devuelve otras ofertas del mismo oferente en caso de no haber coincidencia de etiquetas' do
      crear_usuario
      crear_oferta(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
    
      crear_usuario('Juan', 'Ramirez', 'juan@gmail.com', FECHA_NACIMIENTO_USUARIO)
      crear_oferta('Esclavitud en Java', 'descripcion nueva', MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION)
      
      postularse(id_oferta, 'juan@gmail.com', 'Juan', 'Ramirez', FECHA_NACIMIENTO_USUARIO)
    
      expect(last_response.status).to eq 201
    
      ofertas_sugeridas = respuesta_campo(last_response, 'ofertas_sugeridas')
    
      expect(ofertas_sugeridas).to eq([
        {
          "id" => 2,
          "titulo" => "Esclavitud en Java",
          "descripcion" => "descripcion nueva",
          "mail" => "massiminoagustin@gmail.com",
          "remuneracion" => 3000,
          "ubicacion_oferta" => "Buenos Aires",
          "etiquetas" => nil,
          "edad_minima_postulacion" => 18
        }
      ])
    end

    it 'postular un usuario a una oferta no devuelve ninguna otra si no existen mas ofertas' do
      crear_usuario
      crear_oferta(TITULO_OFERTA, DESCRIPCION_OFERTA, MAIL_USUARIO, REMUNERACION_OFRECIDA, UBICACION_OFERTA, EDAD_MINIMA_POSTULACION, ETIQUETAS)
      id_oferta = respuesta_campo(last_response, 'id_oferta')
    
      crear_usuario('Juan', 'Ramirez', 'juan@gmail.com', FECHA_NACIMIENTO_USUARIO)
      
      postularse(id_oferta, 'juan@gmail.com', 'Juan', 'Ramirez', FECHA_NACIMIENTO_USUARIO)
    
      expect(last_response.status).to eq 201
    
      ofertas_sugeridas = respuesta_campo(last_response, 'ofertas_sugeridas')
    
      expect(ofertas_sugeridas).to eq([])
    end
  end

  describe 'buscar ofertas por titulo' do
    it 'buscar por titulo "ruby" habiendo dos ofertas con "ruby" en el titulo, devuelve un array de 2' do
      crear_usuario
      crear_oferta('dev Ruby', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('ruby ingeniero', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('python dev', DESCRIPCION_OFERTA, MAIL_USUARIO)

      buscar_ofertas_por_titulo('ruBy')
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas').size).to eq 2
    end

    it 'buscar por titulo con menos de 3 caracteres, devuelve un mensaje de error' do
      mensaje_esperado = 'El titulo a buscar debe ser mayor a 3 caracteres.'
      titulo_a_buscar = 'ru'
      crear_usuario
      crear_oferta('dev Ruby', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('ruby ingeniero', DESCRIPCION_OFERTA, MAIL_USUARIO)
      buscar_ofertas_por_titulo(titulo_a_buscar)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end
  end

  describe 'buscar ofertas por etiquetas' do
    it 'debería devolver una lista con todas las ofertas que contienen la etiqueta' do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('dev Ruby',DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)

      buscar_ofertas_por_etiquetas('ruBy')
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas').size).to eq 2
    end

    it 'debería devolver una lista vacía si ninguna oferta contiene la etiqueta' do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('dev Ruby',DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)

      buscar_ofertas_por_etiquetas('linux')
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas').size).to eq 0
    end

    it 'debería devolver una lista con las ofertas que contengan todas las etiquetas buscadas' do
      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('dev Ruby',DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('dev Ruby',DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, 'RUBY')

      buscar_ofertas_por_etiquetas('ruby, tdd')
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas').size).to eq 3
    end

    it 'debería fallar si intento buscar con mas de 5 etiquetas' do
      mensaje_esperado = 'No se aceptan mas de 5 etiquetas'

      crear_usuario
      crear_oferta(TITULO_OFERTA,DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      crear_oferta('dev Ruby',DESCRIPCION_OFERTA,MAIL_USUARIO,REMUNERACION_OFRECIDA,UBICACION_OFERTA,EDAD_MINIMA_POSTULACION, ETIQUETAS)
      
      buscar_ofertas_por_etiquetas('ruby, tdd, dev, job, docker, on rails')
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

    it 'debería fallar si intento buscar por etiquetas Y por titulo' do
      mensaje_esperado = 'Solo puede haber un criterio de busqueda.'

      get '/ofertas/busqueda', { titulo: 'dev Ruby' , etiquetas: 'ruby, TDD'}
      
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end
  end

  describe 'buscar ofertas por usuario' do

    it 'buscar por massiminoagustin@gmail.com habiendo 5 ofertas creadas con mail massiminoagustin@gmail.com, devuelve un array de 5' do
      crear_usuario
      crear_usuario(NOMBRE_USUARIO,APELLIDO_USUARIO,'asdqwf@gqww.net',FECHA_NACIMIENTO_USUARIO)
      crear_oferta('dev Ruby', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('ruby ingeniero', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('python dev', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('dwf dev', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('qdwqw dev', DESCRIPCION_OFERTA, MAIL_USUARIO)
      crear_oferta('achalay dev', DESCRIPCION_OFERTA, 'asdqwf@gqww.net')

      buscar_ofertas_por_usuario(MAIL_USUARIO)
      expect(last_response).to be_ok
      expect(respuesta_campo(last_response, 'ofertas').size).to eq 5
    end

    it 'buscar por rodrigo@cordoba.com sin que este registrado, devuelve un mensaje de error de usuario no registrado' do
      mensaje_esperado = 'Usuario no registrado'
      mail_rodrigo = 'rodrigo@cordoba.com'
      buscar_ofertas_por_usuario(mail_rodrigo)
      expect(last_response.status).to eq 400
      expect(respuesta_campo(last_response, 'error')).to eq mensaje_esperado
    end

  end

end
