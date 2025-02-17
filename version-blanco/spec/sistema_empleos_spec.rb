require 'rspec'
require_relative '../dominio/usuario'
require_relative '../dominio/sistema_empleos'
require_relative '../adaptadores/repositorio_usuarios_redis'
require_relative '../adaptadores/repositorio_ofertas_redis'
require_relative '../adaptadores/manejador_mail'
require_relative '../adaptadores/proveedor_de_fecha'
require_relative '../dominio/excepciones'

NOMBRE_USUARIO = 'Thorfinn'
APELLIDO_USUARIO = 'Thors'
MAIL_USUARIO = 'massiminoagustin@gmail.com' #ESTE MAIL RECIBE CUANDO SE EJECUTA EN ENV TEST
FECHA_NACIMIENTO_USUARIO = '2002-02-20'
TITULO_OFERTA="Dev Ruby on Rails – Web App"
DESCRIPCION_OFERTA="Desarrollador Ruby on Rails para crear y optimizar aplicaciones web. Se requiere experiencia en desarrollo ágil y pruebas automatizadas."
REMUNERACION_OFRECIDA = 3000
UBICACION_OFERTA= 'Buenos Aires '
EDAD_MINIMA_POSTULACION = 18

def inicializar_sistema
  repo_usuarios = RepositorioUsuariosRedis.new
  repo_ofertas = RepositorioOfertasRedis.new
  manejador_mail = ManejadorMail.new
  proovedor_de_fecha = ProveedorDeFecha.new
  sistema = SistemaEmpleos.new(repo_usuarios, repo_ofertas, manejador_mail, proovedor_de_fecha)
  sistema.reset
  return sistema
end

describe 'Sistema Empleos' do
  describe 'registrar usuario' do
    it 'Registrar Usuario devuelve el mail del usuario' do
      sistema = inicializar_sistema
      resultado = sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(resultado).to eq MAIL_USUARIO
    end

    it 'Buscar un mail no existente devuelve error' do
      sistema = inicializar_sistema
      resultado = sistema.usuario_existe('aaaaaaaaaaa@gmail.com')
      expect(resultado).to be false
    end

    it 'Registrar usuario con fecha invalida devuelve error' do
      expect do
        sistema = inicializar_sistema
        sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, '18 de diciembre de 2022')
      end.to(raise_error(FechaInvalida))
    end
  end

  describe 'publicar ofertas' do
    it 'publicar una oferta con etiquetas' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta('titulo', 'descripcion', MAIL_USUARIO, 'etiquetas'=>['ruby', 'tdd'])
      resultado = sistema.listar_ofertas
      oferta = resultado[0]
      expect(oferta.etiquetas[0]).to eq 'ruby'
      expect(oferta.etiquetas[1]).to eq 'tdd'
    end
  end

  describe 'listar ofertas' do
    it 'Listar ofertas sin ofertas devuelve vacio' do
      sistema = inicializar_sistema
      resultado = sistema.listar_ofertas
      expect(resultado[0]).to be nil
    end

    it 'Listar ofertas luego de publicar una oferta la devuelve' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta('titulo', 'descripcion', MAIL_USUARIO)
      resultado = sistema.listar_ofertas
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'titulo'
      expect(oferta.descripcion).to eq 'descripcion'
      expect(oferta.mail).to eq MAIL_USUARIO
    end

    it 'Listar ofertas con remuneracion la lista con este atributo' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta('titulo', 'descripcion', MAIL_USUARIO, 'remuneracion_ofrecida'=> REMUNERACION_OFRECIDA)
      resultado = sistema.listar_ofertas
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'titulo'
      expect(oferta.descripcion).to eq 'descripcion'
      expect(oferta.mail).to eq MAIL_USUARIO
      expect(oferta.remuneracion_ofrecida).to eq REMUNERACION_OFRECIDA
    end

    it 'Listar ofertas con ubicacion de la oferta la lista con este atributo' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta('titulo', 'descripcion', MAIL_USUARIO, 'remuneracion_ofrecida'=> REMUNERACION_OFRECIDA, 'ubicacion_oferta'=> UBICACION_OFERTA)
      resultado = sistema.listar_ofertas
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'titulo'
      expect(oferta.descripcion).to eq 'descripcion'
      expect(oferta.mail).to eq MAIL_USUARIO
      expect(oferta.remuneracion_ofrecida).to eq REMUNERACION_OFRECIDA
      expect(oferta.ubicacion_oferta).to eq UBICACION_OFERTA
    end

    it 'Listar ofertas con edad minima de la oferta la lista con este atributo' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta('titulo', 'descripcion', MAIL_USUARIO, 'remuneracion_ofrecida'=> REMUNERACION_OFRECIDA, 'ubicacion_oferta'=> UBICACION_OFERTA,'edad_minima_postulacion'=> EDAD_MINIMA_POSTULACION)
      resultado = sistema.listar_ofertas
      oferta = resultado[0]
      expect(oferta.id).to eq 1
      expect(oferta.titulo).to eq 'titulo'
      expect(oferta.descripcion).to eq 'descripcion'
      expect(oferta.mail).to eq MAIL_USUARIO
      expect(oferta.remuneracion_ofrecida).to eq REMUNERACION_OFRECIDA
      expect(oferta.ubicacion_oferta).to eq UBICACION_OFERTA
      expect(oferta.edad_minima_postulacion).to eq EDAD_MINIMA_POSTULACION
    end
  end

  describe 'postular usuario a oferta' do
    it 'postular un usuario a una oferta devuelve 202 al enviar mail correctamente' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      id_oferta = sistema.crear_oferta('Esclavitud en Ruby', 'descripcion', MAIL_USUARIO)
      resultado = sistema.postulacion_ofertas(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO, APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      expect(resultado.status_code.to_i).to eq 202
    end

    it 'Si intento postular a un usuario con mail que ya está registrado en esa oferta falla' do
      expect do
        sistema = inicializar_sistema
        sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
        id_oferta = sistema.crear_oferta('Esclavitud en Ruby', 'descripcion', MAIL_USUARIO)
        sistema.postulacion_ofertas(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO, APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
        sistema.postulacion_ofertas(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO, APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      end.to(raise_error(MailYaPostuladoError))
    end

    it 'no se puede postular a una oferta sin cumplir con la edad mínima requerida' do
      expect do
        sistema = inicializar_sistema
        sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
        id_oferta = sistema.crear_oferta('Esclavitud en Ruby', 'descripcion', MAIL_USUARIO, {'edad_minima_postulacion' => 18})
        resultado = sistema.postulacion_ofertas(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO, APELLIDO_USUARIO, '2010-11-10')
      end.to(raise_error(NoCumpleEdadMinimaError))
    end

    it 'postular un usuario a una oferta devuelve 0 sugerencias si no existen mas ofertas en el sistema' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      id_oferta = sistema.crear_oferta('Esclavitud en Ruby', 'descripcion', MAIL_USUARIO)
      resultado = sistema.postulacion_ofertas(id_oferta, MAIL_USUARIO, NOMBRE_USUARIO, APELLIDO_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sugeridas = sistema.ofertas_sugeridas(id_oferta)
      expect(sugeridas.size).to eq 0
    end

    it 'postular un usuario a una oferta devuelve 1 sugerencia del mismo oferente si no hay concidencia de etiquetas' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      sistema.registrar_usuario('Juan', 'Perez', 'juan@mail.com', FECHA_NACIMIENTO_USUARIO)
      etiquetas = ['ruby', 'tdd']
      id_oferta = sistema.crear_oferta('Esclavitud en Ruby', 'descripcion', MAIL_USUARIO, { 'etiquetas' => etiquetas })
      id_oferta2 = sistema.crear_oferta('Esclavitud en Java', 'descripcion numero 2', MAIL_USUARIO)
      resultado = sistema.postulacion_ofertas(id_oferta, 'juan@mail.com', 'Juan', 'Perez', FECHA_NACIMIENTO_USUARIO)
      sugeridas = sistema.ofertas_sugeridas(id_oferta)
      expect(sugeridas.size).to eq 1
      expect(sugeridas[0].titulo).to eq 'Esclavitud en Java'
    end
  end

  describe 'buscar oferta por titulo' do
 
    it 'crear una oferta y buscarla por titulo devuelve el titulo - camino feliz' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas'
      descripcion_oferta = 'soy descripcion de hola tarolas'
      sistema.crear_oferta(titulo_oferta, descripcion_oferta, MAIL_USUARIO)
      ofertas_encontradas= sistema.buscar_ofertas_por_titulo('holatarolas')
      expect(ofertas_encontradas.size).to eq(1)
    end

    it 'se crea más de una oferta con un mismo titulo y buscar oferta por titulo devuelve 2' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas'
      titulo_oferta_2 = 'cebolla'
      sistema.crear_oferta(titulo_oferta, DESCRIPCION_OFERTA, MAIL_USUARIO)
      sistema.crear_oferta(titulo_oferta, DESCRIPCION_OFERTA, MAIL_USUARIO)
      sistema.crear_oferta(titulo_oferta_2, DESCRIPCION_OFERTA, MAIL_USUARIO)
      ofertas_encontradas = sistema.buscar_ofertas_por_titulo('holatarolas')
      expect(ofertas_encontradas.size).to eq(2)
    end

    it 'se crean 2 ofertas con titulo que incluye la palabra holatarolas y devuelve 2' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas cerealmix'
      titulo_oferta_2 = 'asd holatarolas'
      titulo_oferta_3 = 'cebolla'
      sistema.crear_oferta(titulo_oferta, DESCRIPCION_OFERTA, MAIL_USUARIO)
      sistema.crear_oferta(titulo_oferta_2, DESCRIPCION_OFERTA, MAIL_USUARIO)
      sistema.crear_oferta(titulo_oferta_3, DESCRIPCION_OFERTA, MAIL_USUARIO)
      ofertas_encontradas = sistema.buscar_ofertas_por_titulo('holatarolas')
      expect(ofertas_encontradas.size).to eq(2)
    end
  end


  describe 'buscar oferta por usuario' do
 
    it 'crear una oferta y buscarla por mail de usuario devuelve la oferta - camino feliz' do
      sistema = inicializar_sistema
      mail = 'mate@gmail.com'
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, mail, FECHA_NACIMIENTO_USUARIO)
      sistema.crear_oferta(TITULO_OFERTA, DESCRIPCION_OFERTA, mail)
      ofertas_encontradas= sistema.buscar_ofertas_por_usuario(mail)
      expect(ofertas_encontradas.size).to eq(1)
    end

    it 'se crea más de una oferta con un mismo usuario y buscar oferta por usuario devuelve 3' do
      sistema = inicializar_sistema
      mail = 'mate@gmail.com'
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, mail, FECHA_NACIMIENTO_USUARIO)
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, 'wfjiowqdq@gmail.com', FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas'
      titulo_oferta_2 = 'cebolla'
      sistema.crear_oferta(titulo_oferta, DESCRIPCION_OFERTA, mail)
      sistema.crear_oferta(titulo_oferta, DESCRIPCION_OFERTA, mail)
      sistema.crear_oferta(titulo_oferta_2, DESCRIPCION_OFERTA, mail)
      sistema.crear_oferta('dsijqwoifhd', 'fioqjwd02jd', 'wfjiowqdq@gmail.com')
      ofertas_encontradas = sistema.buscar_ofertas_por_usuario(mail)
      expect(ofertas_encontradas.size).to eq(3)
    end

    it 'se intenta buscar una oferta con un usuario no registrado y lanza excepcion' do
      expect do
        sistema = inicializar_sistema
        mail = 'mate@gmail.com'
        ofertas_encontradas = sistema.buscar_ofertas_por_usuario(mail)
      end.to(raise_error(UsuarioNoRegistrado))
      
    end
  end

  describe 'buscar ofertas por etiquetas' do
    it 'se busca una oferta con una etiqueta y la devuelve' do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas'
      descripcion_oferta = 'soy descripcion de hola tarolas'
      etiquetas = ['ruby', 'tdd']
      sistema.crear_oferta(titulo_oferta, descripcion_oferta, MAIL_USUARIO, { 'etiquetas' => etiquetas })
      ofertas_encontradas= sistema.buscar_ofertas_por_etiquetas(['ruby'])
      expect(ofertas_encontradas.size).to eq(1)
    end
  end

  it 'no se puede buscar más de 5 etiquetas' do
    expect do
      sistema = inicializar_sistema
      sistema.registrar_usuario(NOMBRE_USUARIO, APELLIDO_USUARIO, MAIL_USUARIO, FECHA_NACIMIENTO_USUARIO)
      titulo_oferta = 'holatarolas'
      descripcion_oferta = 'soy descripcion de hola tarolas'
      etiquetas = ['ruby', 'tdd']
      sistema.crear_oferta(titulo_oferta, descripcion_oferta, MAIL_USUARIO, { 'etiquetas' => etiquetas })
      ofertas_encontradas= sistema.buscar_ofertas_por_etiquetas(['ruby', 'tdd', 'linux', 'rails', 'job', 'docker'])
    end.to(raise_error(EtiquetasCantidadError))
  end
end

