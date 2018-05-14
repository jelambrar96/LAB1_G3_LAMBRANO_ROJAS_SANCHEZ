import numpy as np
import matplotlib.pyplot as plt

def main():

    # frecuencia y periodo de la onda que se
    # desea obtener a la salida
    FREQ = 60 #60hz
    period = 1.0/FREQ

    # steps 256 * PREESCALER
    # step = 512.0 * 10**-6

    # numero de muestras para un semiciclo
    # nstep = int(0.5*period/step)
    # print('numero de muestras por semiciclo:')
    # print(nstep)

    # tabla de valores
    table = []

    f = open('output3.txt', 'w')

    for i in range(32):
        item= int(round(255 - 1 * 255 * np.sin(np.pi*i/32)))
        if (item > 253):
            item = 253
        #print(item)
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')

        item = 255 - item
        if(item > 253):
            item = 253
        #print(item)
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')
    	#f.write('---------------------------------------\n')

    f.close()

    fig = plt.figure()

    y1 = table[0::2]
    y2 = table[1::2]
    x = range(len(y1))
    plt.plot(x,y1,x,y2)
    plt.show()


if __name__ == '__main__':
    main()
