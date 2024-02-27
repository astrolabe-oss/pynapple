import {
  to = aws_key_pair.infra_2024_1_30_1
  id = "infra_2024_1_30_1"
}

resource "aws_key_pair" "infra_2024_1_30_1" {
  key_name   = "infra_2024_1_30_1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC9zgieiSccrGwMFsUOOmZHszZgp7xZQRWtexHnva5iftiwoU1K1A78j8VDxibKl7OiRnoMo2TXJzvrbxvtB+XfsTAtk1tmuwi4d6BMytNNWL/tfPqNHobJiayjXadyLX+u2Ym/MEp4eOxkI78G1tfRIGLM/08NG8r8vltyPBpeU9K0wK79WAzmHGFOEv7RLKZI67GHrXnf/CL8UIZAwtx0uAKjHUtgLlnHSuA+kbACqAO4Pl6N96/OAuBnXMxfgmteV/AE3HhqJLYTqZvLR141IFQL/Pwtcuyh6csxLX2jDivFt8MO/lrTM3YOrgNgN7mgOwmrIB6G6NGydrN4Sl5R infra_2024_1_30_1\n"
  tags = local.common_tags
}