def sqlFormat(value):
    if type(value) == int:
        return str(value)
    elif value.startswith('0b'):
        return value
    else:
        return '"{}"'.format(value)


def tuplesToList(tuples, schema):
    result = []
    for tuple in tuples:
        entry = {}
        for i in range(len(tuple)):
            entry[schema[i]] = tuple[i]
        result.append(entry)
    return result

def arrayDictToMatrix(dictionary):
    array = []
    for row in dictionary.keys():
        array.append(dictionary[row])
    return array


def columnMinimum(matrix):
    minimums = []
    rows = len(matrix)
    cols = len(matrix[0])
    for j in range(cols):
        min = matrix[0][j]
        for i in range(1, rows):
            if matrix[i][j] < min:
                min = matrix[i][j]
        minimums.append(min)
    return minimums


def columnSum(matrix):
    sums = []
    rows = len(matrix)
    cols = len(matrix[0])
    for j in range(cols):
        sum = 0
        for i in range(rows):
            sum += matrix[i][j]
        sums.append(sum)
    return sums


def rowSum(matrix):
    sums = []
    rows = len(matrix)
    cols = len(matrix[0])
    for i in range(rows):
        sum = 0
        for j in range(cols):
            sum += matrix[i][j]
        sums.append(sum)
    return sums


def distribute(value, data, distParameter):
    dataMatrix = arrayDictToMatrix(data)
    rows = len(dataMatrix)
    cols = len(dataMatrix[0])
    colMinimums = columnMinimum(dataMatrix)
    matrixParameters = []
    for i in range(cols):
        distParameter[i] = int(value * distParameter[i])
    for i in range(rows):
        matrixParameters.append([])
    for j in range(cols):
        for i in range(rows):
            matrixParameters[i].append(dataMatrix[i][j] / colMinimums[j])
    matrixColSum = columnSum(matrixParameters)
    for i in range(cols):
        distParameter[i] = distParameter[i] / matrixColSum[i]
    for j in range(cols):
        for i in range(rows):
            matrixParameters[i][j] = int(matrixParameters[i][j] * distParameter[j])
    matrixRowSum = rowSum(matrixParameters)
    keys = list(data.keys())
    distTotal = 0
    for i in range(rows):
        distTotal += matrixRowSum[i]
        data[keys[i]] = matrixRowSum[i]
    data[keys[0]] = data[keys[0]] + (value - distTotal)
    return data
