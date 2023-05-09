//
//  CoinImageView.swift
//  MyBatt
//
//  Created by 김태윤 on 2023/05/07.
//

import SwiftUI



struct CoinImageView: View {
    @StateObject var vm: CoinImageViewModel
    init(coin: CoinModel){
//        self._vm = CoinImageViewModel(coin: coin)
        print("CoinImageView init")
        self._vm = StateObject(wrappedValue: CoinImageViewModel(coin: coin))
    }
    var body: some View {
        ZStack{
            if vm.isLoading{
                ProgressView()
            }else{
                if let image = vm.image{
                    Image(uiImage: image)
                }else{
                    Image(systemName: "questionmark")
                }
            }
        }
    }
}

struct CoinImageView_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageView(coin: globalCoinDemo)
    }
}
let globalCoinDemo = CoinModel(id: "bitcoin", symbol: "btc", name: "비트코인", image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579", currentPrice: 28868, marketCap: 559612318701, marketCapRank: 1, fullyDilutedValuation: 606817896506, totalVolume: 15726123182, high24H: 29358, low24H: 28485, priceChange24H: -488.9607440462132, priceChangePercentage24H: -1.66559, marketCapChange24H: -8478660884.788086, marketCapChangePercentage24H: -1.49248, circulatingSupply: 19366368, totalSupply: 21000000, maxSupply: 21000000, ath: 69045, athChangePercentage: -58.14876, athDate: "2021-11-10T14:24:11.849Z", atl: 67.81, atlChangePercentage: 42513.94551, atlDate: "2013-07-06T00:00:00.000Z", roi: nil, lastUpdated: "2023-05-07T09:28:52.830Z", sparklineIn7D: SparklineIn7D(price: [
    29276.108913477685,
    29297.557760171887,
    29304.936378904236,
    29283.490347075323,
    29281.867356125804,
    29235.08720835631,
    29220.379573384813,
    29269.01110839384,
    29303.604571274605,
    29440.282586791018,
    29809.777245111778,
    29738.619547451064,
    29739.909871176587,
    29656.712525700674,
    29358.65872538205,
    29348.7423117686,
    29441.591555817897,
    29400.03166363632,
    29362.056213625394,
    29305.597130735507,
    28842.654479443805,
    28595.976831538992,
    28580.88076874382,
    28552.261450541097,
    28431.23932123237,
    28598.795164199157,
    28642.326585104187,
    28616.77340607422,
    28580.081949322015,
    28560.37211812579,
    28561.586978241772,
    28620.46425358391,
    28529.56502313481,
    28472.791278383647,
    28167.747949221648,
    28385.38324568294,
    28301.509742037444,
    28171.60655909179,
    27892.437319554825,
    27740.332253000946,
    28013.592969040943,
    28007.360195708872,
    28125.501155636823,
    28099.747789189736,
    28011.58808678877,
    27999.89784922244,
    28029.23641973025,
    27974.18817870787,
    28000.6177745973,
    28002.239483655878,
    28030.141380509038,
    28043.644977077103,
    27996.19326596321,
    28024.76710826783,
    28073.41150317945,
    28163.199242190058,
    28011.987254151092,
    28470.55539908227,
    28528.537485217974,
    28482.582111875538,
    28599.969298825374,
    28725.894198521066,
    28748.042943001867,
    28706.92346797802,
    28675.05800276479,
    28777.605218075783,
    28654.390133326717,
    28619.059219824012,
    28542.667469803946,
    28522.6998550533,
    28531.103614134492,
    28526.836496395514,
    28480.278495073115,
    28616.142974697006,
    28663.727712396598,
    28733.4319728726,
    28665.88859502708,
    28663.80893264078,
    28609.887497548385,
    28402.58177797949,
    28326.55934195484,
    28255.902587948047,
    28337.46391936188,
    28396.598344559814,
    28576.620707641123,
    28435.09833343794,
    28382.60560068505,
    28395.19443551921,
    28965.927272881996,
    29081.325675810822,
    28988.320996249273,
    29088.144016544065,
    29042.288848721226,
    29050.827890734534,
    29106.65001871619,
    29111.885410176983,
    29200.31858051141,
    29176.598225915513,
    29078.472181376357,
    29087.861031094635,
    29069.40363420366,
    29254.716934816213,
    29167.57369162784,
    29083.836681572473,
    28802.76354147552,
    28857.00705990738,
    28879.36144570229,
    28928.724358922926,
    28854.970014956503,
    28779.46443527096,
    28877.42240761657,
    28857.4859838944,
    28848.73904161497,
    28812.38631133332,
    28855.84922975481,
    28935.14345343107,
    29342.79068227058,
    29291.972286618195,
    29178.31797115364,
    29271.817542725108,
    29232.028333691127,
    29222.237458958556,
    29107.55537018495,
    29084.470543140567,
    29101.74129290109,
    29123.471027953066,
    29126.246354587835,
    29061.097134105,
    29113.834094598107,
    29314.966379854686,
    29328.912603777735,
    29530.221370924588,
    29533.622860993983,
    29413.766893530334,
    29495.26291890936,
    29559.076431197333,
    29530.151331551937,
    29642.231838723994,
    29520.322268970496,
    29724.410733072382,
    29583.277182450165,
    29486.507801238855,
    29383.59000478144,
    29394.894605708298,
    29397.936862857005,
    29381.25174792024,
    29423.979863370678,
    29364.835600369996,
    29354.211750544386,
    29288.831274548353,
    29285.380854238454,
    29106.451367250607,
    28991.84168921723,
    28647.05194551684,
    28633.39383146063,
    28728.65342715058,
    28829.16983916026,
    28929.911269932716,
    28901.2653693351,
    28853.024378356,
    28813.74848761159,
    28899.71077009776,
    28887.741045523366,
    28975.20623386575,
    28989.377250937963,
    28892.512520602326,
    28828.399821938965,
    28873.58657503555
  ]), priceChangePercentage24HInCurrency: -1.6655928412473038 , currentHoldings: 2)