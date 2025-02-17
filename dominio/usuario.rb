require_relative 'excepciones'

class Usuario
  REGEX_MAIL = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  REGEX_CARACTERES = /\A[a-zA-Z\s]*\z/
  CARACTERES_MINIMOS = 3
  attr_reader :mail, :nombre, :apellido, :fecha_nacimiento

  def initialize(nombre, apellido, mail, fecha_nacimiento)
    validar_parametros(nombre, apellido, mail)
    @nombre = nombre
    @mail = mail
    @apellido = apellido
    @fecha_nacimiento = fecha_nacimiento
  end

  def validar_parametros(nombre, apellido, mail)
    raise EmailInvalidoError unless mail.to_s =~ REGEX_MAIL
    raise NombreCortoError unless nombre.size >= CARACTERES_MINIMOS
    raise NombreInvalidoError unless nombre.to_s =~ REGEX_CARACTERES
    raise ApellidoCortoError unless apellido.size >= CARACTERES_MINIMOS
    raise ApellidoInvalidoError unless apellido.to_s =~ REGEX_CARACTERES
  end
end
