export CUDA_VISIBLE_DEVICES=$1

if [ ! -f ./train.tsv ]; then
  wget http://atp-modelzoo-sh.oss-cn-shanghai.aliyuncs.com/release/tutorials/classification/train.tsv
fi

if [ ! -f ./dev.tsv ]; then
  wget http://atp-modelzoo-sh.oss-cn-shanghai.aliyuncs.com/release/tutorials/classification/dev.tsv
fi

MASTER_ADDR=localhost
MASTER_PORT=$(shuf -n 1 -i 10000-65535)
GPUS_PER_NODE=1
NNODES=1
NODE_RANK=0

DISTRIBUTED_ARGS="--nproc_per_node $GPUS_PER_NODE --nnodes $NNODES --node_rank $NODE_RANK --master_addr $MASTER_ADDR --master_port $MASTER_PORT"

mode=$2

if [ "$mode" = "train" ]; then

  python -m torch.distributed.launch $DISTRIBUTED_ARGS examples/appzoo_tutorials/sequence_classification/bert_classify/main.py \
    --mode $mode \
    --worker_gpu=1 \
    --tables=train.tsv,dev.tsv \
    --input_schema=label:str:1,sid1:str:1,sid2:str:1,sent1:str:1,sent2:str:1 \
    --first_sequence=sent1 \
    --second_sequence=sent2 \
    --label_name=label \
    --label_enumerate_values=0,1 \
    --checkpoint_dir=./classification_model/ \
    --learning_rate=3e-5  \
    --epoch_num=300  \
    --random_seed=42 \
    --save_checkpoint_steps=500 \
    --sequence_length=128 \
    --micro_batch_size=16 \
    --app_name=text_classify \
    --user_defined_parameters='
        pretrain_model_name_or_path=roberta-large-en
    '

elif [ "$mode" = "evaluate" ]; then

  python -m torch.distributed.launch $DISTRIBUTED_ARGS main.py \
  --mode=$mode \
  --worker_gpu=1 \
  --tables=dev.tsv \
  --input_schema=label:str:1,sid1:str:1,sid2:str:1,sent1:str:1,sent2:str:1 \
  --first_sequence=sent1 \
  --second_sequence=sent2 \
  --label_name=label \
  --label_enumerate_values=0,1 \
  --checkpoint_dir=./classification_model \
  --sequence_length=128 \
  --micro_batch_size=32 \
  --app_name=text_classify

elif [ "$mode" = "predict" ]; then

  python -m torch.distributed.launch $DISTRIBUTED_ARGS examples/appzoo_tutorials/sequence_classification/bert_classify/main.py \
  --mode=$mode \
  --worker_gpu=1 \
  --tables=nlu_text.tsv \
  --outputs=sentiment.pred.tsv \
  --input_schema=sent1:str:1,content:str:1,pos:str:1,ner:str:1 \
  --output_schema=predictions \
  --append_cols=sent1,pos \
  --first_sequence=sent1 \
  --second_sequence=sent1 \
  --checkpoint_path=./classification_model \
  --micro_batch_size 32 \
  --sequence_length=128 \
  --app_name=text_classify

fi
