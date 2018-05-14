import numpy as np 

def main():
    
    # frecuencia y periodo de la onda que se 
    # desea obtener a la salida 
    FREQ = 60 #60hz    
    period = 1.0/FREQ    
    
    # steps 
    step = 512.0 * 10**-6
    
    # numero de muestras
    nstep = int(period/step)
    
    # tabla de valores 
    table = []
    
    f = open('output.txt', 'w')
    
    for i in range(nstep):
        item= int(round(255 - 1 * 255 * np.sin(np.pi*FREQ*(i + 0.5)*step)))
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')
    
    f.write('---------------------------------------\n')
    
    for i in range(nstep):
        item = 255 - table[i]
        table.append(item)
        f.write('retlw\t' + str(hex(item)) + '\n')
    
    
    f.close()

if __name__ == '__main__':
    main()
