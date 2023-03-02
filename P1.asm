#MENDEZ SANTANA JAZMIN NAHIL 734043
#GONZALEZ CAMACHO LAURA GRISELDA 734049
.data
		# [ A B C ]
	dir: .word 0 0 0 #[0, 4, 8]
	A: .word

.text
	main:
		addi s0, zero, 3 #Numero de discos
		lui s1, %hi(A) #Guarda la parta alta del arreglo
		addi s1, s1, %lo(A) #Guarda parte baja del arreglo
		lui s3, %hi(dir)#Guarda la parta alta del arreglo
		addi s3, s3, %lo(dir)#Guarda parte baja del arreglo
		add s2, zero, s0 #copia de n
		addi a4, zero, 1 #valor 1
		add a7, zero, zero #bandera para saber si hacemos return normal o con sp/ra
		add t0, zero, zero #Contador para saltar memoria
		j initialize #inicializamos las torres
		
		
	initialize:
		sw s2, 0(s1) #llenamos la torre A de n a 1
		addi s1, s1, 4 #nos movemos 4 en el arreglo
		addi t0, t0, 4 #aumentamos el contador
		addi s2, s2, -1 #Disminuye n
		bne s2, zero, initialize #llenamos torre A de n discos
		addi s1, s1, -4 #colocamos s1 en el ultimo elemento de la torre A
		add t1, zero, s1 # -> TORRE A
		sw t1, 0(s3) #Guadamos en el arreglo
		addi t2, t1, 4 #->TORRE B -> el siguiente lugar de la torre A
		add t3, t2, t0 # ->TORRE C -> dejamos el espacio en memoria suficiente para n discos en B y empezamos la torre C
		addi t3, t3, -4 #Al saber que el primer movimiento es un push a B y/o C restamos un lugar...
		addi t2,t2, -4#para al momento de realizar push quedar en el ultimo elemento de la torre
		sw t2, 4(s3)#Guardamos en el arreglo
		sw t3, 8(s3)#Guadamos en el arreglo
		add s2, zero, s0 #Volvemos a copiar n
		jal ra, hanoi #saltamos a la funcion recursiva
		j end
	
	hanoi:
		addi sp, sp, -4 #Guardo el valor de ra en el stack
		sw ra, 0(sp)
		addi sp, sp, -4 #Solicito otro espacio y guardo n
		sw s2, 0(sp)	#De ser n == 1 realizamos un Pop y despues un Push
		beq s2, a4, PopPush #POP-> A(a1) PUSH->C(a3)
		addi s2, s2, -1	#de no ser 1, llamamos a la funcion con n-1 y un orden diferente de las torres
		jal ra Intercambio_CB	#Orden-> (A, C, B) -> (a1, a3, a2) 
		jal ra hanoi	#Con esos nuevos datos de entrada volvemos a llamar a la funcion
		#Se llegara aqui una vez n ya haya sido 1, por lo que se requiere realizar un popPush pero
		#Con el orden de las torres original (antes de cambiar el orden)
		addi a7, zero, 1 #Activamos nuestra bandera, para saber se realizara un return normal es decir sin utilizar valores del stack
		jal ra Intercambio_CB #Ordenamos de regreso nuestas torres
		jal ra PopPush #Realizamos un pop y un push (siempre un pop a la torre A y un push a la C)
		#Desactivamos la bandera, ya que el proximo return si sera con uso de stack
		add a7, zero, zero
		jal ra Intercambio_AB #Ahora, volvemos a llamar a la funcion pero con el orden ( B, A, C)
		jal ra hanoi
		#Regresamos al orden normal ABC para continuar con la recursividad
		jal ra Intercambio_AB
		jal ra return_hanoi #Realizamos un return a una direccion del stack
	
	#[0,  4,   8]
	#[A,  B,  C ]
	
	Intercambio_CB:
		#[ A B C]->[ A C B ]
		#A permanece igual
		lw t1, 4(s3)#Obtenemos B
		lw t2, 8(s3)#Obtenemos C
		sw t2, 4(s3)#Intercambiamos valores
		sw t1, 8(s3)
		jalr ra #Regresamos
		
	Intercambio_AB:
		#[ A B C]->[ B A C ]
		lw t1, 4(s3)#Obtenemos B
		lw t2, 0(s3)#Obtenemos A
		sw t1, 0(s3) #Intercambiamos valores
		sw t2, 4(s3)
		#C permanece igual
		jalr ra #Regresamos
		
		
	PopPush:
		lw t0, 0(s3) #Guardamos el dato de a1 -> Torre A
		lw t1, 0(t0)#Valor de la torre A
		sw zero, 0(t0) #Ponemos un cero en dicha Torre y posicion
		addi t0, t0, -4 #Disminuimos la longitud de la torre
		sw t0, 0(s3)
		lw t3, 8(s3) #Obtenemos la torre C
		addi t3, t3, 4 #Aumentamos la longitud de la Torre C
		sw t1, 0(t3)#Guardamos en la Torre C el valor de la Torre A
		sw t3, 8(s3)
		beq a7, zero, return_hanoi #Si se trata de un PopPush activado por la condicional n == 1, realizaremos un return con uso de ra
		j normal_ret #Si se trata de un PopPush que no depende de la condicional, se hara un return normal, regresando a la funcion
		
	return_hanoi:
		lw s2, 0(sp)#Obtenemos el valor de la ultima n
		addi sp, sp, 4
		lw ra, 0(sp) #Obtenemos el valor del salto dentro de la funcion hanoi
		addi sp, sp, 4 #nos volvemos a posicionar en el siguiente valor de n
		jalr ra #saltamos a en medio de la funcion
		
	normal_ret:
		jalr ra #Regresa a la funcion
		
	end: #final