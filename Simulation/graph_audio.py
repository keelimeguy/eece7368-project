import matplotlib.pyplot as plt
import matplotlib
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('filename')
    parser.add_argument('--start', '-s', default=0, type=float, help='Starting time to graph in millisec')
    parser.add_argument('--end', '-e', default=None, type=float, help='Ending time to graph in millisec')
    args = parser.parse_args()

    x = []
    y = []
    i = int(args.start*100000)
    with open(args.filename, 'rb') as f:
        f.seek(i)
        byte = f.read(1)
        while byte:
            time = 10*i

            if (args.end is None) or (args.end >= time / 1000000):
                y.append(0 if byte == b'\x00' else 1)
                x.append(time)
                if x[-1] % 1000000 == 0:
                    print('{} ms'.format(x[-1] / 1000000), end='\r', flush=True)

            else:
                break

            i += 1
            byte = f.read(1)

    print('\ndone')

    fig, ax = plt.subplots()
    ax.plot(x, y)

    fig.savefig("audio.png")
    plt.show()
