require_relative './usuario'
require_relative './oferta'
require_relative './excepciones'

class SistemaEmpleos
  def initialize(repositorio_usuarios, repositorio_ofertas, manejador_mail, proovedor_de_fecha)
    @repositorio_usuarios = repositorio_usuarios
    @repositorio_ofertas = repositorio_ofertas
    @manejador_mail = manejador_mail
    @proovedor_de_fecha = proovedor_de_fecha
  end

  def registrar_usuario(nombre, apellido, mail, fecha_nacimiento)
    usuario = Usuario.new(nombre, apellido, mail,
                          @proovedor_de_fecha.parsear_fecha(fecha_nacimiento))
    @repositorio_usuarios.guardar(usuario)
    usuario.mail
  end

  def crear_oferta(titulo, descripcion, mail, parametros_opcionales = {})
    raise UsuarioNoRegistrado unless usuario_existe(mail)

    oferta = Oferta.new(
      titulo,
      descripcion,
      mail,
      parametros_opcionales.transform_keys(&:to_sym)
    )

    @repositorio_ofertas.guardar(oferta)
  end

  def usuario_existe(mail)
    !@repositorio_usuarios.recuperar(mail).nil?
  end

  def listar_ofertas
    @repositorio_ofertas.listar
  end

  def postulacion_ofertas(id_oferta, mail_usuario_postulado, nombre_usuario_postulado, apellido_usuario_postulado, fecha_nacimiento_postulado)
    usuario = Usuario.new(nombre_usuario_postulado, apellido_usuario_postulado, mail_usuario_postulado, @proovedor_de_fecha.parsear_fecha(fecha_nacimiento_postulado))
    oferta = @repositorio_ofertas.recuperar(id_oferta)
    oferta.validar_postulacion(usuario, oferta, @proovedor_de_fecha)
    oferta.agregar_mail_postulante(usuario.mail)
    @repositorio_ofertas.guardar(oferta)
    @manejador_mail.send_mail(oferta.mail, oferta.titulo, usuario.nombre, usuario.apellido,
                              usuario.mail)
  end

  def buscar_ofertas_por_titulo(titulo)
    validar_longitud_titulo(titulo)
    @repositorio_ofertas.buscar_por_titulo(titulo.downcase)
  end

  def buscar_ofertas_por_usuario(usuario_buscado)
    raise UsuarioNoRegistrado unless usuario_existe(usuario_buscado)

    listar_ofertas.select { |oferta| oferta.mail.downcase == usuario_buscado.downcase }
                  .map { |oferta| oferta_a_hash(oferta) }
  end

  def buscar_ofertas_por_etiquetas(etiquetas)
    raise EtiquetasCantidadError if etiquetas.size > 5

    @repositorio_ofertas.buscar_por_etiqueta(etiquetas)
  end

  def ofertas_sugeridas(id_oferta)
    oferta_actual = @repositorio_ofertas.recuperar(id_oferta)
    ofertas_coincidentes = ordenar_ofertas(oferta_actual,
                                           obtener_ofertas_coincidentes(oferta_actual))

    if ofertas_coincidentes.size < 3
      restantes = buscar_ofertas_del_mismo_oferente(oferta_actual) - ofertas_coincidentes
      ofertas_coincidentes.concat(restantes)
    end
    ofertas_coincidentes.take(3)
  end

  def validar_longitud_titulo(titulo)
    raise TituloABuscarInvalido if titulo.length < 3
  end

  def reset
    @repositorio_usuarios.reset
    @repositorio_ofertas.reset
  end

  private

  def oferta_a_hash(oferta)
    {
      id: oferta.id,
      titulo: oferta.titulo,
      descripcion: oferta.descripcion,
      mail: oferta.mail,
      remuneracion: oferta.remuneracion_ofrecida,
      ubicacion_oferta: oferta.ubicacion_oferta,
      edad_minima_postulacion: oferta.edad_minima_postulacion,
      etiquetas: oferta.etiquetas
    }
  end

  def obtener_ofertas_coincidentes(oferta_actual)
    etiquetas = oferta_actual.etiquetas
    listar_ofertas.select do |oferta|
      unless oferta.etiquetas.nil?
        (oferta.etiquetas & etiquetas).any? && oferta.id != oferta_actual.id
      end
    end
  end

  def ordenar_ofertas(oferta_actual, ofertas_coincidentes)
    etiquetas = oferta_actual.etiquetas
    ofertas_coincidentes.sort_by { |oferta| -(oferta.etiquetas & etiquetas).size }
  end

  def buscar_ofertas_del_mismo_oferente(oferta_actual)
    listar_ofertas.select do |oferta|
      oferta.id != oferta_actual.id && oferta.mail == oferta_actual.mail
    end
  end
end
