require 'rspec'
require_relative '../dominio/sistema_empleos'
require_relative '../dominio/usuario'
require_relative '../dominio/oferta'
require_relative '../adaptadores/repositorio_ofertas_redis'
require_relative '../adaptadores/repositorio_usuarios_redis'
require_relative '../adaptadores/proveedor_de_fecha'

repo_usuarios = RepositorioUsuariosRedis.new
repo_ofertas = RepositorioOfertasRedis.new
proveedor_de_fecha = ProveedorDeFecha.new

sistema_empleos = SistemaEmpleos.new(repo_usuarios, repo_ofertas, proveedor_de_fecha)

def registrar_usuario_valido
  nombre = 'sabri'
  apellido = 'garcia'
  mail = 'sab@gmail.com'
  fecha_nacimiento = '1999-01-28'
  suscripcion = 'gratuita'
  sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
end

describe 'Sistema empleos' do
  before(:each) do
    sistema_empleos.reset
  end

  it 'se inicializa con dos repositorios vacio' do
    expect(sistema_empleos.cantidad_de_ofertas).to eq 0
    expect(sistema_empleos.cantidad_de_usuarios).to eq 0   
  end

  describe 'usuarios' do
    it 'agrega un usuario al repositorio de usuarios del sistema' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'

      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      expect(sistema_empleos.cantidad_de_usuarios).to eq 1
      expect(id_usuario).to eq mail
    end

    it 'no se puede agregar un usuario al sistema sin fecha de nacimiento' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = ''
      suscripcion = 'gratuita'

      expect{ sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion) }.to raise_error(ParametroAusente)
    end

    it 'no se puede agregar un usuario al sistema con una fecha de nacimiento de formato distinto a AAAA-MM-DD' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '28-01-1999'
      suscripcion = 'gratuita'

      expect{ sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion) }.to raise_error(FormatoNoValido)
    end

    it 'no se puede agregar un usuario al sistema con una fecha de nacimiento que no es valida' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1985-05-45'
      suscripcion = 'gratuita'

      expect{ sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion) }.to raise_error(DatoNoValido)
    end

    it 'no se puede agregar un usuario al sistema con con edad menor a 18 años' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '2007-10-31'
      suscripcion = 'gratuita'

      ENV['fecha'] = '2024-10-31'
      expect{ sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion) }.to raise_error(DatoNoValido)
    end

    it 'no se puede registrar un usuario con un mail que ya esta en uso' do
      nombre = 'esteban'
      apellido = 'gonzalez'
      mail = 'esteban@gmail.com'
      fecha_nacimiento = '2000-10-31'
      suscripcion = 'gratuita'

      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      nombre2 = 'jesus'
      apellido2 = 'perez'
      fecha_nacimiento2 = '2000-11-22'
      suscripcion2 = 'gratuita'

      expect{ sistema_empleos.registrar_usuario(nombre2, apellido2, mail, fecha_nacimiento2, suscripcion2) }.to raise_error(MailYaRegistrado)
    end

    it 'no se puede registrar un usuario con un mail que ya esta en uso en mayusculas' do
      nombre = 'esteban'
      apellido = 'gonzalez'
      mail = 'esteban@gmail.com'
      fecha_nacimiento = '2000-10-31'
      suscripcion = 'gratuita'

      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      nombre2 = 'jesus'
      apellido2 = 'perez'
      mail2 = 'ESTEBAN@gmail.com'
      fecha_nacimiento2 = '2000-11-22'
      suscripcion2 = 'gratuita'
      
      expect{ sistema_empleos.registrar_usuario(nombre2, apellido2, mail2, fecha_nacimiento2, suscripcion2) }.to raise_error(MailYaRegistrado)
    end
  end

  describe 'ofertas' do
    it 'agrega una oferta al repositorio de ofertas del sistema' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)

      expect(sistema_empleos.cantidad_de_ofertas).to eq 1
      expect(id_oferta).to eq 1
    end

    it 'lanza error si se intenta publicar una oferta con un usuario no registrado en el sistema' do      
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      mail = 'sab@gmail.com'

      expect{sistema_empleos.registrar_oferta(titulo, descripcion, mail)}.to raise_error(UsuarioNoRegistrado)
      expect(sistema_empleos.cantidad_de_ofertas).to eq 0
    end

    it 'lista todas las ofertas publicadas' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'corporativa'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      titulo2 = "Titulo de otra oferta"
      descripcion2 = "Esto es la descripcion de otra oferta de trabajo. Tiene otros datos sobre la otra oferta."
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      id_oferta2 = sistema_empleos.registrar_oferta(titulo2, descripcion2, id_usuario)

      ofertas = sistema_empleos.listar_todas_las_ofertas

      expect(ofertas[0][1]['titulo']).to eq titulo
      expect(ofertas[0][1]['descripcion']).to eq descripcion
      expect(ofertas[0][1]['id_usuario']).to eq id_usuario

      expect(ofertas[1][2]['titulo']).to eq titulo2
      expect(ofertas[1][2]['descripcion']).to eq descripcion2
      expect(ofertas[1][2]['id_usuario']).to eq id_usuario
    end

    it 'lanza error si se intenta publicar una oferta sin un mail' do  
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      mail = ""
      expect{sistema_empleos.registrar_oferta(titulo, descripcion, mail)}.to raise_error(ParametroAusente)
    end

    it 'agrega una oferta al repositorio de ofertas del sistema si el mail se pasa en mayuscula pero existe en el repositorio' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      id_usuario = 'SAB@GMAIL.COM'
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)

      expect(sistema_empleos.cantidad_de_ofertas).to eq 1
      expect(id_oferta).to eq 1
    end

    it 'agrega una oferta al repositorio de ofertas del sistema con edad mínima' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario, 20, nil)

      expect(sistema_empleos.cantidad_de_ofertas).to eq 1
      expect(sistema_empleos.consultar_oferta(id_oferta).edad_minima).to eq 20
      expect(id_oferta).to eq 1
    end

  end

  describe 'consultar ofertas' do
    it 'consulta los datos de una oferta que esta en el repositorio de ofertas' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      
      oferta_consultada = sistema_empleos.consultar_oferta(id_oferta)

      expect(sistema_empleos.cantidad_de_ofertas).to eq 1
      expect(oferta_consultada.titulo).to eq "Titulo de Oferta"
      expect(oferta_consultada.usuario.apellido).to eq 'garcia'
      expect(oferta_consultada.descripcion).to eq "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
    end

    it 'consultar los datos de una oferta que no existe deberia devolver error' do      
      id_oferta = 1

      expect{ sistema_empleos.consultar_oferta(id_oferta) }.to raise_error(OfertaNoEncontrada)
    end

    it 'consultar todas las ofertas de un usuario' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'corporativa'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      id_oferta2 = sistema_empleos.registrar_oferta("Otro titulo de oferta", descripcion, id_usuario)
      

      id_usuario2 = sistema_empleos.registrar_usuario('luli', 'germano', 'luli@gmail.com', '2000-03-04', 'gratuita')
      titulo = "El titulo de otra Oferta"
      descripcion = "Esto es la descripcion de otra oferta. Tiene otros datos sobre la otra oferta."
      id_oferta2 = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario2)

      ofertas_usuario1 = sistema_empleos.encontrar_ofertas_usuario(id_usuario)
      expect(ofertas_usuario1.size).to eq 2
    end
  end

  describe 'limite de ofertas por usuario' do
    it 'contar ofertas de un usuario en el mes' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'corporativa'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta("Otro titulo de oferta", descripcion, id_usuario)
      
      
      id_usuario2 = sistema_empleos.registrar_usuario('luli', 'germano', 'luli@gmail.com', '2000-03-04', 'corporativa')
      titulo = "El titulo de otra Oferta"
      descripcion = "Esto es la descripcion de otra oferta. Tiene otros datos sobre la otra oferta."
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario2)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario2)

      ofertas_mes_us2 = sistema_empleos.ofertas_del_mes(id_usuario2)
      expect(ofertas_mes_us2).to eq 2
    end

    it 'deberia fallar si un usuario con suscripcion gratuita intenta hacer mas de una oferta en un mes' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, 'gratuita')

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)

      expect{ sistema_empleos.registrar_oferta("Otro titulo de oferta", descripcion, id_usuario) }.to raise_error(LimiteDePublicacionesAlcanzado)
    end

    it 'deberia fallar si un usuario con suscripcion profesional intenta hacer mas de cinco ofertas en un mes' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, 'profesional')

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)

      expect{ sistema_empleos.registrar_oferta("Otro titulo de oferta", descripcion, id_usuario) }.to raise_error(LimiteDePublicacionesAlcanzado)
    end

    it 'deberia poder publicar ilimitadas ofertas por mes si el usuario tiene suscripcion corporativa' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, 'corporativa')

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario)
      id_oferta = sistema_empleos.registrar_oferta("Otro titulo de oferta", descripcion, id_usuario) 
      expect(id_oferta).to eq 6
    end
  end

  describe 'actualizar oferta' do
    it 'se actualizan los datos de una oferta ya existente' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      titulo = "Titulo de Oferta"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      edad_minima = '25'
      edad_maxima = '50'
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario, edad_minima, edad_maxima)
      fecha_original = sistema_empleos.consultar_oferta(id_oferta).fecha_publicacion
      descripcion_actualizada = "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      edad_minima_actualizada = '30'
      edad_maxima_actualizada = '40'
      opcionales = { edad_minima: edad_minima_actualizada, edad_maxima: edad_maxima_actualizada }
      
      id_oferta_actualizada = sistema_empleos.actualizar_oferta(descripcion_actualizada, id_usuario, id_oferta, opcionales)

      oferta_consultada = sistema_empleos.consultar_oferta(id_oferta_actualizada)

      expect(oferta_consultada.titulo).to eq "Titulo de Oferta"
      expect(oferta_consultada.descripcion).to eq "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      expect(oferta_consultada.edad_minima).to eq "30"
      expect(id_oferta_actualizada).to eq 1
      expect(oferta_consultada.fecha_publicacion).to eq fecha_original
      expect(oferta_consultada.edad_maxima).to eq "40"
    end

    it 'deberia lanzar error si se intenta actualizar una oferta con distinto dueño' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)

      nombre2 = 'rodrigo'
      apellido2 = 'gaitan'
      mail2 = 'rodrigo@gmail.com'
      fecha_nacimiento2 = '2002-01-28'
      suscripcion2 = 'gratuita'
      id_usuario2 = sistema_empleos.registrar_usuario(nombre2, apellido2, mail2, fecha_nacimiento2, suscripcion2)

      titulo = "Titulo valido"
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      edad_minima = '25'
      edad_maxima = '50'
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario, edad_minima, edad_maxima)
      
      descripcion_actualizada = "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      edad_minima_actualizada = '30'
      edad_maxima_actualizada = '40'
      opcionales = { edad_minima: edad_minima_actualizada, edad_maxima: edad_maxima_actualizada }

      expect{ sistema_empleos.actualizar_oferta(descripcion_actualizada, id_usuario2, id_oferta, opcionales) }.to raise_error(MailNoAutorizado)
    end

    it 'deberia lanzar error si intento actualizar una oferta que no existe' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      descripcion_actualizada = "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      edad_minima_actualizada = '30'
      edad_maxima_actualizada = '40'
      opcionales = { edad_minima: edad_minima_actualizada, edad_maxima: edad_maxima_actualizada }

      id_oferta = 1

      expect{ sistema_empleos.actualizar_oferta(descripcion_actualizada, id_usuario, id_oferta, opcionales) }.to raise_error(OfertaNoEncontrada)
    end

    it 'deberia lanzar error si intento actualizar una oferta con una edad minima menor a 18' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = 'Titulo valido'
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      edad_minima = '25'
      edad_maxima = '50'
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario, edad_minima, edad_maxima)

      descripcion_actualizada = "Esto es la descripcion de la oferta actualizada. Tiene datos sobre la oferta actualizada."
      edad_minima_actualizada = '15'
      edad_maxima_actualizada = '40'
      opcionales = { edad_minima: edad_minima_actualizada, edad_maxima: edad_maxima_actualizada }

      expect{ sistema_empleos.actualizar_oferta(descripcion_actualizada, id_usuario, id_oferta, opcionales) }.to raise_error(DatoNoValido)
    end

    it 'deberia lanzar error si intento actualizar una oferta y no pongo una descripcion' do
      nombre = 'sabri'
      apellido = 'garcia'
      mail = 'sab@gmail.com'
      fecha_nacimiento = '1999-01-28'
      suscripcion = 'gratuita'
      id_usuario = sistema_empleos.registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
      
      titulo = 'Titulo valido'
      descripcion = "Esto es la descripcion de la oferta. Tiene datos sobre la oferta."
      edad_minima = '25'
      edad_maxima = '50'
      id_oferta = sistema_empleos.registrar_oferta(titulo, descripcion, id_usuario, edad_minima, edad_maxima)

      descripcion_actualizada = ''
      edad_minima_actualizada = '15'
      edad_maxima_actualizada = '40'
      opcionales = { edad_minima: edad_minima_actualizada, edad_maxima: edad_maxima_actualizada }

      expect{ sistema_empleos.actualizar_oferta(descripcion_actualizada, id_usuario, id_oferta, opcionales) }.to raise_error(ParametroAusente)
    end
  end
end
