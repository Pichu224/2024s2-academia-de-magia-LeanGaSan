class Cosa {
	const property marca 
	const property volumen 
	const property esMagico
	const property esReliquia

	method utilidad() {
		return volumen + self.valorMagico() + self.valorReliquia() + self.utilidadDeMarca()
	}

	method valorMagico() = if(esMagico) 3 else 0
	method valorReliquia() = if(esReliquia) 5 else 0

	method utilidadDeMarca() = marca.aporte(self)
}

object cuchuflito {
	method aporte(cosa) {
		return 0
	}
}

object fenix {
	method aporte(cosa) {
		return if(cosa.esReliquia()) 3 else 0
	}
}

object acme {
	method aporte(cosa) {
		return cosa.volumen() / 2
	}
}

class Mueble {
	var property inventario = #{}

	method tiene(cosa) {
		return inventario.contains(cosa)
	}

	method guardar(cosa) {
		inventario.add(cosa)
	}

	method utilidad() {
		return self.utilidadDeCosasAlmacenadas() / self.precio()
	}

	method utilidadDeCosasAlmacenadas() {
		return inventario.sum({cosa => cosa.utilidad()})
	}

	method cosaMenosUtil() {
		return inventario.min({cosa => cosa.utilidad()})
	}

	method sacar(cosa) {
		inventario.remove(cosa)
	}

	method precio()
	method puedeGuardar(cosa)
}

class Baul inherits Mueble{
	var property volumenMaximo

	method volumenTotal() {
		return inventario.sum({cosa => cosa.volumen()})
	}

	override method puedeGuardar(cosa) {
		return self.volumenTotal() + cosa.volumen() <= volumenMaximo
	}

	override method precio() {
		return volumenMaximo + 2
	}

	override method utilidad() {
		return super() + self.valorReliquias()
	}

	method valorReliquias() {
	  	return if(self.sonTodasLasCosasReliquias()) 2 else 0
	}

	method sonTodasLasCosasReliquias() {
		return inventario.all({cosa => cosa.esReliquia()})
	}
}

class BaulMagico inherits Baul{
	override method utilidad() {
		return super() + self.valorMagicos()
	}

	method valorMagicos() {
		return inventario.filter({cosa => cosa.esMagico()}).size()
	}

	override method precio() {
		return super() * 2
	}
}

class GabineteMagico inherits Mueble{
	const property precio

	override method puedeGuardar(cosa) {
		return cosa.esMagico()
	}
}

class Armario inherits Mueble{
	var property cantidadMaxima 

	override method puedeGuardar(cosa) {
		return inventario.size() < cantidadMaxima
	}

	override method precio() {
		return 5 * cantidadMaxima
	}
}

class Academia {
	var property muebles = #{}

	// punto 1
	method estaGuardada(cosa) {
		return muebles.any({mueble => mueble.tiene(cosa)})
	}
	// punto 2
	method enQueMuebleEsta(cosa) {
		return muebles.find({mueble => mueble.tiene(cosa)})
	}

	// punto 3
	method puedeGuardar(cosa) {
		return !self.estaGuardada(cosa) and self.hayMuebleDisponiblePara(cosa)
	}

	method hayMuebleDisponiblePara(cosa) {
		return muebles.any({mueble => mueble.puedeGuardar(cosa)})
	}

	//punto 4
	method enQueMueblesPuedeGuardar(cosa) {
		return muebles.filter({mueble => mueble.puedeGuardar(cosa)})
	}

	//punto 5
	method guardar(cosa) {
		self.verificarGuardar(cosa)
		self.guardarCosaEnPrimerMuebleDisponible(cosa)
	}

	method verificarGuardar(cosa) {
		if(!self.puedeGuardar(cosa)) {
			self.error("No se puede guardar")
		}
	}

	method guardarCosaEnPrimerMuebleDisponible(cosa) {
		self.enQueMueblesPuedeGuardar(cosa).anyOne().guardar(cosa)
	}	

	//punto 2.2
	method cosasMenosUtiles() {
		return muebles.map({mueble => mueble.cosaMenosUtil()}).asSet()
	}

	//punto 2.3
	method marcaDeLaCosaMenosUtil() {
		return self.cosasMenosUtiles().min({cosa => cosa.utilidad()}).marca()
	}

	//punto 2.4
	method sacarCosasMenosUtilesYMagicas() {
		self.validarCantidadDeMuebles()
		self.sacarCosas()
	}

	method validarCantidadDeMuebles() {
		if(!(muebles.size() >= 3)) {
			self.error("No se pueden sacar las cosas")
		}
	}

	method sacarCosas() {
		self.cosasMenosUtilesNoMagicas().forEach({cosa => self.enQueMuebleEsta(cosa).sacar(cosa)})
	}

	method cosasMenosUtilesNoMagicas() {
		return self.cosasMenosUtiles().filter({cosa => !cosa.esMagico()})
	}
}