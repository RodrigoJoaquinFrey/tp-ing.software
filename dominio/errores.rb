## General

class ParametroAusente < StandardError; end

class CantidadDeCaracteresNoValida < StandardError; end

class FormatoNoValido < StandardError; end

class DatoNoValido < StandardError; end

## Sistema Empleos

class UsuarioNoRegistrado < StandardError; end

class MailYaRegistrado < StandardError; end

class MailNoAutorizado < StandardError; end

class LimiteDePublicacionesAlcanzado < StandardError; end

## Repositorio Ofertas Redis

class OfertaNoEncontrada < StandardError; end
