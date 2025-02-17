class MetodosWebApp
  def validar_parametros_no_nil(diccionario_de_parametros_esperados)
    diccionario_de_parametros_esperados.each do |clave, valor|
      return clave if valor.nil? || valor.to_s.strip.empty?
    end
    nil
  end

  def transformar_ofertas_en_dict(lista_de_ofertas)
    lista_de_ofertas.map do |oferta|
      { id: oferta.id, titulo: oferta.titulo, descripcion: oferta.descripcion,
        mail_oferente: oferta.mail, remuneracion_ofrecida: oferta.remuneracion_ofrecida,
        ubicacion_oferta: oferta.ubicacion_oferta, edad_minima_postulacion: oferta.edad_minima_postulacion,
        etiquetas: oferta.etiquetas}
    end
  end

  def transformar_etiquetas_en_array(string_etiquetas)
    array_etiquetas = string_etiquetas.split(',')
    array_etiquetas.map!(&:strip)
    array_etiquetas.map(&:downcase)
  end
end
