# -*- coding: utf-8 -*-

import numpy as np


def main():
    # frecuencia y periodo de la onda que se
    # desea obtener a la salida
    FREQ = 60
    print(('Frecuencia: ' + str(FREQ)))
    period = 1.0 / FREQ
    print(('Periodo: ' + str(period * 1000) + ' ms'))
    semicicle = 0.5 * period
    print(('Semiciclo: ' + str(semicicle * 1000) + ' ms'))
    # numero de intervalos en los que se desea
    # dividir el simicilo
    n = 32
    print(('numero de intervalos: ' + str(n)))
    # ancho de cada intevarlo
    ancho_intervalo = semicicle / n
    print(('ancho de cada semiciclo: ' + str(ancho_intervalo * 10 ** 6) +
    ' us'))
    # frecuencia de operacion del pic
    freq_pic = 20.0 * 10 ** 6
    print(('Frecuencia de operacion del PIC ' +
    str(freq_pic / (1.0 * 10 ** 6)) + ' Mz'))
    # ciclo de reloj sin preescaler
    clock_cicle = 4.0 / freq_pic
    print(('ciclo de reloj del pic: ' + str(clock_cicle * 10 ** 9) + ' ns'))
    # maximo valor del registro
    max_reg = 256
    # valor recomendado del preescaler
    init_preescaler = semicicle / (n * max_reg * clock_cicle)
    preescaler = 1
    while(True):
        preescaler = preescaler * 2
        if(preescaler > init_preescaler):
            break
    print(('preescaler  = ' + str(preescaler)))
    # valor del temporizador
    temp_val = int(semicicle / (n * preescaler * clock_cicle))
    print(('El valor que guarda el temporizador es: ' + str(temp_val)))
    # lo modifica el usuario
    temp = 152
    # abre el archivo donde se guardara la tabla
    table_file = open('final_table_pwm.txt', 'w')
    # ummbra
    umbral = 254
    for i in range(n):
        # agrega el periodo de trabajo
        time = int(round(temp * np.sin(np.pi * (i + 0.5) / n)))
        item = max_reg - 1 - time
        if (item > umbral):
            item = umbral
        table_file.write('\t\tretlw\t' + str(hex(item)) + '\n')
        # agrega el periodo muerto
        time = temp - time
        item = max_reg - 1 - time
        if (item > umbral):
            item = umbral
        table_file.write('\t\tretlw\t' + str(hex(item)) + '\n')
    # cierra el archivo
    table_file.close()

if __name__ == '__main__':
    main()
