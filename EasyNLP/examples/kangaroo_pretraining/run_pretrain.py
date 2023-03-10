import sys

sys.path.append('./')
sys.path.append('./easynlp/appzoo/')
sys.path.append('./easynlp/appzoo/sequence_classification/')

print('*'*50)
print('running local main...\n')
from easynlp.core import Trainer
from easynlp.appzoo import get_application_evaluator

from easynlp.appzoo import LanguageModelingDataset
from easynlp.appzoo.language_modeling.model import LanguageModeling
from easynlp.utils import initialize_easynlp, get_args, get_pretrain_model_path
from easynlp.utils.global_vars import parse_user_defined_parameters


if __name__ == "__main__":
    # os.environ["NCCL_DEBUG_SUBSYS"] = "ALL"
    # os.environ["NCCL_DEBUG"] = "INFO"

    initialize_easynlp()
    args = get_args()


    print('log: starts to process user params...\n')
    user_defined_parameters = parse_user_defined_parameters(args.user_defined_parameters)
    if args.mode == 'train' or not args.checkpoint_dir:
        args.pretrained_model_name_or_path = user_defined_parameters.get('pretrain_model_name_or_path')
    else:
        args.pretrained_model_name_or_path = args.checkpoint_dir
    args.pretrained_model_name_or_path = get_pretrain_model_path(args.pretrained_model_name_or_path)

    print('pretrained_model_name_or_path', args.pretrained_model_name_or_path)

    print('log: starts to process dataset...\n')
    train_dataset = LanguageModelingDataset(
        pretrained_model_name_or_path=args.pretrained_model_name_or_path,
        data_file=args.tables.split(",")[0],
        max_seq_length=args.sequence_length,
        input_schema=args.input_schema,
        first_sequence=args.first_sequence,
        second_sequence=args.second_sequence,
        label_name=args.label_name,
        label_enumerate_values=args.label_enumerate_values,
        user_defined_parameters=user_defined_parameters,
        is_training=True)

    valid_dataset = LanguageModelingDataset(
        pretrained_model_name_or_path=args.pretrained_model_name_or_path,
        data_file=args.tables.split(",")[-1],
        max_seq_length=args.sequence_length,
        input_schema=args.input_schema,
        first_sequence=args.first_sequence,
        second_sequence=args.second_sequence,
        label_name=args.label_name,
        label_enumerate_values=args.label_enumerate_values,
        user_defined_parameters=user_defined_parameters,
        is_training=False)

    model = LanguageModeling(pretrained_model_name_or_path=args.pretrained_model_name_or_path)

    trainer = Trainer(model=model, train_dataset=train_dataset, user_defined_parameters=user_defined_parameters)
    trainer.train()
