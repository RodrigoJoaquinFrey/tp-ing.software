require_relative 'usuario'
require_relative 'oferta'

require 'date'

class SistemaEmpleos
  def initialize(repositorio_usuarios, repositorio_ofertas, proveedor_de_fecha)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_ofertas = repositorio_ofertas
    @proveedor_de_fecha = proveedor_de_fecha
  end

  def reset
    @repositorio_usuarios.reset
    @repositorio_ofertas.reset
  end

  def cantidad_de_ofertas
    @repositorio_ofertas.size
  end

  def cantidad_de_usuarios
    @repositorio_usuarios.size
  end

  def registrar_usuario(nombre, apellido, mail, fecha_nacimiento, suscripcion)
    fecha_actual = fecha_de_hoy
    validar_suscripcion(suscripcion)

    datos_personales = {'nombre' => nombre, 'apellido' => apellido, 'mail' => mail,
                        'fecha_nacimiento' => fecha_nacimiento}
    usuario = Usuario.new(datos_personales, fecha_actual:, suscripcion:)

    verificar_mail_no_registrado(mail)
    @repositorio_usuarios.guardar(usuario)
    usuario.obtener_id
  end

  def registrar_oferta(titulo, descripcion, mail, edad_minima = nil, edad_maxima = nil)
    validar_mail_para_oferta(mail)
    usuario = obtener_usuario(mail)
    validar_suscripcion_para_publicar(usuario)

    datos_oferta = { 'titulo' => titulo, 'descripcion' => descripcion }
    fecha_publicacion = fecha_de_hoy
    oferta = Oferta.new(datos_oferta, usuario, fecha_publicacion, edad_minima, edad_maxima)
    @repositorio_ofertas.guardar(oferta)
  end

  def actualizar_oferta(descripcion, mail_usuario, id_oferta, opcionales = {})
    validar_mail_para_oferta(mail_usuario)
    oferta_original = obtener_oferta_por_id(id_oferta)
    validar_autorizacion_para_actualizar(mail_usuario, oferta_original)

    oferta_actualizada = crear_oferta_actualizada(descripcion, oferta_original, opcionales)
    @repositorio_ofertas.guardar_actualizacion(oferta_actualizada, id_oferta)
  end

  def consultar_oferta(id_oferta)
    @repositorio_ofertas.encontrar(id_oferta)
  end

  def listar_todas_las_ofertas
    @repositorio_ofertas.listar_todas
  end

  def encontrar_ofertas_usuario(id_usuario)
    @repositorio_ofertas.encontrar_todas_id(id_usuario)
  end

  def fecha_de_hoy
    @proveedor_de_fecha.ver_fecha
  end

  def ofertas_del_mes(id_usuario)
    ofertas = encontrar_ofertas_usuario(id_usuario)
    ofertas.count { |oferta| este_mes?(Date.parse(oferta.values.first['fecha_publicacion'])) }
  end

  private

  def crear_oferta_actualizada(descripcion, oferta_original, opcionales)
    datos_oferta = { 'titulo' => oferta_original.titulo, 'descripcion' => descripcion }
    Oferta.new(datos_oferta, oferta_original.usuario, oferta_original.fecha_publicacion,
               opcionales[:edad_minima], opcionales[:edad_maxima])
  end

  def obtener_usuario(mail)
    usuario = @repositorio_usuarios.encontrar(mail.downcase)
    raise UsuarioNoRegistrado, 'mail no corresponde a un usuario registrado' if usuario.nil?

    usuario
  end

  def verificar_mail_no_registrado(mail)
    return unless @repositorio_usuarios.encontrar(mail.downcase)

    raise MailYaRegistrado, 'Este mail ya esta registrado'
  end

  def validar_suscripcion(suscripcion)
    return unless suscripcion.nil? || suscripcion.empty?

    raise ParametroAusente, 'se necesita un tipo de suscripcion para registrar el usuario'
  end

  def validar_suscripcion_para_publicar(usuario)
    tipo_suscripcion = usuario.suscripcion
    return unless no_puede_registrar?(usuario.obtener_id, tipo_suscripcion)

    raise LimiteDePublicacionesAlcanzado, 'la suscripcion no permite hacer mas publicaciones'
  end

  def validar_mail_para_oferta(mail)
    return unless mail.nil? || mail.empty?

    raise ParametroAusente, 'se necesita un mail para publicar una oferta'
  end

  def obtener_oferta_por_id(id_oferta)
    @repositorio_ofertas.encontrar(id_oferta)
  end

  def validar_autorizacion_para_actualizar(mail_usuario, oferta)
    return unless oferta.usuario.obtener_id != mail_usuario.downcase

    raise MailNoAutorizado, 'Solamente el dueño de la oferta puede actualizarla'
  end

  def no_puede_registrar?(id_usuario, tipo_suscripcion)
    ofertas_del_mes(id_usuario) >= tipo_suscripcion.limite_mensual
  end

  def este_mes?(fecha)
    fecha.year == fecha_de_hoy.year && fecha.month == fecha_de_hoy.month
  end
end
