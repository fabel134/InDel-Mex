import os
from statistics import median
import sys
import matplotlib.pyplot as plt

path = sys.argv[1]
outFileName = sys.argv[2]
#outFileName = "marzo22"
#path = 'D:/documents/OneDrive/trabajo/genomica/langebio/covid/marzo22/'
out = open(os.path.join(path,outFileName+'depthReport.tsv'),'w')
print(out)

if len(sys.argv) <= 2:
    print("arguments: <path to depth tsv files> <report file name>")
    exit(0)

coverages = dict()
# iterate over all samples in the path
for filename in os.listdir(path):
# skip non tsv files in the path
    if "tsv" not in filename or outFileName in filename:
        continue
    f = open(os.path.join(path,filename),'r')
    coverageSample = dict()
    cumm = 0
# parse coverage for all positions of a sample
    for line in f:
    # sample line:
    # C_045512.2     1       0
        fields = line.replace('\n','').split('\t')
        pos = int(fields[1])
        cov = int(fields[2]) 
        coverageSample[pos] = cov
        cumm += cov
# store depth of sample in coverages
    for pos in coverageSample.keys():
        if pos not in coverages.keys():
            coverages[pos] = list()
        coverages[pos].append( coverageSample[pos] )

# calculate median
coveragesMedian = dict()
coveragesGreater20 = dict()
coveragesZero = dict()

coveragesMedianZoom = dict()
coveragesGreater20Zoom = dict()
coveragesZeroZoom = dict()

for pos,coverageList in coverages.items():
    coverageList.sort()
    coveragesMedian[pos] = coverageList[ int(len(coverageList)/2) ]
    #coveragesMedian[pos] = median(coverageList)
    if median(coverageList)>= 20:
        coveragesGreater20[pos] =1
    else:
        coveragesGreater20[pos] = 0
    if median(coverageList) >0:
        coveragesZero[pos] = 1
    else:
        coveragesZero[pos] = 0

    if pos > 20000 and pos < 25000:
        coveragesMedianZoom[pos] = coverageList[ int(len(coverageList)/2) ]
        #coveragesMedian[pos] = median(coverageList)
        if median(coverageList)>= 20:
            coveragesGreater20Zoom[pos] =1
        else:
            coveragesGreater20Zoom[pos] = 0
        if median(coverageList) >0:
            coveragesZeroZoom[pos] = 1
        else:
            coveragesZeroZoom[pos] = 0



# generate graphs

fig, ax = plt.subplots()
ax.scatter(coveragesMedian.keys(), coveragesMedian.values(), s = 2)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage")
fig.savefig(os.path.join(path,outFileName+"Coverage.png"))

fig, ax = plt.subplots()
ax.scatter(coveragesZero.keys(), coveragesZero.values(), s = 5)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage greater than zero")
fig.savefig(os.path.join(path,outFileName+"CoverageZeros.png"))

fig, ax = plt.subplots()
ax.scatter(coveragesGreater20.keys(), coveragesGreater20.values(), s = 5)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage greater than 20")
fig.savefig(os.path.join(path,outFileName+"CoverageGreater20.png"))

# zoomed to positions 20,000 to 25,000
fig, ax = plt.subplots()
ax.scatter(coveragesMedianZoom.keys(), coveragesMedianZoom.values(), s = 2)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage")
fig.savefig(os.path.join(path,outFileName+"CoverageZoom.png"))

fig, ax = plt.subplots()
ax.scatter(coveragesZeroZoom.keys(), coveragesZeroZoom.values(), s = 5)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage greater than zero")
fig.savefig(os.path.join(path,outFileName+"CoverageZerosZoom.png"))

fig, ax = plt.subplots()
ax.scatter(coveragesGreater20Zoom.keys(), coveragesGreater20Zoom.values(), s = 5)
ax.set_xlabel("position")
ax.set_ylabel("number of reads")
ax.set_title("Read coverage greater than 20")
fig.savefig(os.path.join(path,outFileName+"CoverageGreater20Zoom.png"))



# write tsv report
for pos, median in coveragesMedian.items():
    out.write(str(pos) + "\t"+str(median)+"\n")
#    out.write(f"{pos}\t{median}\n")
out.close()
