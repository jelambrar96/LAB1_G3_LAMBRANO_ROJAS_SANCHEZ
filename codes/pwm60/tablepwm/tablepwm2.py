import numpy as np

def main():

    # frecuencia y periodo de la onda que se
    # desea obtener a la salida
    FREQ = 60 #60hz
    period = 1.0/FREQ

    # steps 256 * PREESCALER
    step = 512.0 * 10**-6

    # numero de muestras para un semiciclo
    nstep = int(0.5*period/step)
    print('numero de muestras por semiciclo:')
    print(nstep)

    # tabla de valores
    table = []

    f = open('output2.txt', 'w')

    for i in range(16):
        item= int(round(255 - 1 * 255 * np.sin(2*np.pi*FREQ*(i + 0.5)*step)))
        print(item)
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')

        item = 255 - item
        print(item)
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')
    	#f.write('---------------------------------------\n')

    f.close()

if __name__ == '__main__':
    main()
