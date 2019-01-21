# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=binboost --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=BinGAN128b --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=BinGAN128f --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=brief --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=deepdesc-ubc --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=geodesc --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=hardnet-liberty --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=hardnet-liberty-hpatches --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=HRankSIFTB_LB --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=HRankSIFT_LB --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=l2net-hpatches --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=l2net-liberty --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=orb --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=rootsift --split=a --task=matching  --task=retrieval  --task=verification --delimiter=";"
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=sift --split=a --task=matching  --task=retrieval  --task=verification --delimiter=";"
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=spheredesc-hpatches --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=spheredesc-liberty --split=a --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=tfeat-liberty --split=a --task=matching  --task=retrieval  --task=verification

# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=binboost --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=BinGAN128b --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=BinGAN128f --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=brief --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=deepdesc-ubc --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=geodesc --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=hardnet-liberty --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=hardnet-liberty-hpatches --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=HRankSIFTB_LB --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=HRankSIFT_LB --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=l2net-hpatches --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=l2net-liberty --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=orb --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=rootsift --split=full --task=matching  --task=retrieval  --task=verification --delimiter=";"
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=sift --split=full --task=matching  --task=retrieval  --task=verification  --delimiter=";"
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=spheredesc-hpatches --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=spheredesc-liberty --split=full --task=matching  --task=retrieval  --task=verification
# python3 hpatches_eval.py --descr-dir=../data/descriptors/ --descr-name=tfeat-liberty --split=full --task=matching  --task=retrieval  --task=verification

python3 hpatches_results.py --results-dir=results/ --descr=sift --descr=deepdesc-ubc --descr=tfeat-liberty --descr=SphereDesc_LIB+ --descr=spheredesc-hpatches --descr=hardnet-liberty --descr=geodesc --split=full

# python3 hpatches_results.py --results-dir=results/ --descr=sift --descr=BinGAN128b --descr=BinGAN128f --descr=brief --descr=HRankSIFTB_LB --descr=HRankSIFT_LB --descr=LearnedSIFT --descr=NCC --descr=orb --descr=VGG --split=full

#python3 hpatches_results.py --results-dir=results/ --descr=sift --descr=orb --descr=tfeat-liberty --descr=SphereDesc_LIB+ --split=a
