func isSubset(_ arrayA: [Character], _ arrayB: [Character]) -> Bool {

    let setA = Set(arrayA)
    let setB = Set(arrayB)
    
    for char in setB {
        if !setA.contains(char) {
            return false
        }
    }
    
    return true
}

isSubset(["A","B","C","D","E"], ["A","D","E"])
isSubset(["A","B","C","D","E"], ["A","D","Z"])
isSubset(["A","D","E"], ["A","A","D","E"])


//O(n^2)
//for the element quantities "n" of longest array, the maximum comparing times is n * n times


func nextFibonacci(_ arr: [Int]) {
    
    var series = [1,1]
    var dict = [1:2]
    var sortedArr = arr.sorted()
    
    while true {
        series.append(series[0]+series[1])
        if sortedArr[0] <= series[1] {
            dict[sortedArr[0]] = (sortedArr[0] < series[1]) ? series[1] : series[2]
            sortedArr.remove(at: 0)
            if sortedArr.isEmpty {
                break
            }
        }
        series.remove(at: 0)
    }
    
    for i in arr {
        print(dict[i]!)
    }
}

nextFibonacci([1,22,9])
