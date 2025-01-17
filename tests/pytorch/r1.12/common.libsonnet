// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

local common = import '../common.libsonnet';
local experimental = import '../experimental.libsonnet';
local mixins = import 'templates/mixins.libsonnet';
local utils = import 'templates/utils.libsonnet';
local volumes = import 'templates/volumes.libsonnet';

{
  local r1_12 = {
    frameworkPrefix: 'pt-r1.12',
    tpuSettings+: {
      softwareVersion: 'pytorch-1.12',
    },
    imageTag: 'r1.12',
  },
  PyTorchTest:: common.PyTorchTest + r1_12,
  PyTorchXlaDistPodTest:: common.PyTorchXlaDistPodTest + r1_12,
  PyTorchGkePodTest:: common.PyTorchGkePodTest + r1_12,
  Functional:: mixins.Functional {
    schedule: '0 7 * * *',
    tpuSettings+: {
      preemptible: false,
    },
  },
  Convergence:: mixins.Convergence,
  PyTorchTpuVmMixin:: experimental.PyTorchTpuVmMixin {
    tpuSettings+: {
      softwareVersion: 'tpu-vm-base',
      tpuVmPytorchSetup: |||
        sudo pip3 uninstall --yes torch torch_xla torchvision numpy
        sudo pip3 install https://storage.googleapis.com/tpu-pytorch/wheels/tpuvm/torch-1.12-cp38-cp38-linux_x86_64.whl
        sudo pip3 install https://storage.googleapis.com/tpu-pytorch/wheels/tpuvm/torch_xla-1.12-cp38-cp38-linux_x86_64.whl
        sudo pip3 install https://storage.googleapis.com/tpu-pytorch/wheels/tpuvm/torchvision-1.12-cp38-cp38-linux_x86_64.whl
        sudo pip3 install https://storage.googleapis.com/cloud-tpu-tpuvm-artifacts/wheels/libtpu-nightly/libtpu_nightly-0.1.dev20220518-py3-none-any.whl
        sudo pip3 install numpy
        sudo pip3 install mkl mkl-include cloud-tpu-client
        sudo apt-get -y update
        sudo apt-get install -y libomp5
        # No need to check out the PyTorch repository, but check out PT/XLA at
        # pytorch/xla anyway
        mkdir pytorch
        cd pytorch
        git clone https://github.com/pytorch/xla.git -b r1.12
      |||,
    },
  },
  datasetsVolume: volumes.PersistentVolumeSpec {
    name: 'pytorch-datasets-claim',
    mountPath: '/datasets',
  },

  // DEPRECATED: Use PyTorchTpuVmMixin instead
  tpu_vm_1_12_install: self.PyTorchTpuVmMixin.tpuSettings.tpuVmPytorchSetup,
}
