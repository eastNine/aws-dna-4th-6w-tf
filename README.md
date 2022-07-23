# 실행 순서
1. terraform 준비
```shell
terraform init
```

2. Console에서 EC2 key pair 생성 후 terraform으로 가져오기
```
# key pair name을 dna로 생성한 경우
terraform import aws_key_pair.ec2_key dna
```

3. windows에 접속하는 환경의 IP를 your_ip 환경변수에 입력 (https://www.whatismyip.com 같은 곳에서 얻을 수 있음)
```
# variables.tf
variable "your_ip" {
  description = "Input your public IP"
  type        = string
  default     = "0.0.0.0/0" # HERE
}
```

4. Resource 배포
```
terraform plan
terraform apply
```